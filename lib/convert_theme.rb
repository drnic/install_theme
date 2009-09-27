$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'hpricot'
require 'rubigen'
require 'rubigen/scripts/generate'

class ConvertTheme
  VERSION = "0.3.0"
  
  attr_reader :template_root, :rails_root, :index_path, :template_type
  attr_reader :stylesheet_dir, :javascript_dir, :image_dir
  attr_reader :content_id, :inside_yields
  attr_reader :stdout
  attr_reader :inside_yields_originals
  
  def initialize(options = {})
    @template_root  = File.expand_path(options[:template_root] || File.dirname('.'))
    @rails_root     = File.expand_path(options[:rails_root] || File.dirname('.'))
    @template_type  = (options[:template_type] || detect_template).to_s
    @index_path     = options[:index_path] || "index.html"
    @content_id     = options[:content_id] || "content"
    @inside_yields  = options[:inside_yields] || {}
    @stylesheet_dir = options[:stylesheet_dir] || detect_stylesheet_dir
    @javascript_dir = options[:javascript_dir] || detect_javascript_dir
    @image_dir      = options[:image_dir] || detect_image_dir
    @stdout         = options[:stdout] || $stdout
    
    setup_template_temp_path
  end
  
  def apply_to_target(options = {})
    @stdout = options[:stdout] || @stdout || $stdout
    @inside_yields_originals = {}
    convert_file_to_layout(index_path, 'app/views/layouts/application.html.erb')
    prepare_assets
    run_generator(options)
    show_readme
  end
  
  # This generator's templates folder is temporary
  # and is accessed via source_root within the generator.
  def template_temp_path
    @template_temp_path ||= begin
      tmp_dir = ENV['TMPDIR'] || '/tmp'
      template_path = File.join(tmp_dir, "convert_theme", "templates")
    end
  end
  
  def setup_template_temp_path
    FileUtils.rm_rf(template_temp_path)
    FileUtils.mkdir_p(template_temp_path)
    %w[app/views/layouts public/images public/javascripts public/stylesheets].each do |app_path|
      FileUtils.mkdir_p(File.join(template_temp_path, app_path))
    end
  end
  
  def haml?
    template_type == 'haml'
  end
  
  def erb?
    template_type == 'erb'
  end
  
  protected
  
  def convert_file_to_layout(html_path, layout_path)
    File.open(File.join(template_temp_path, layout_path), "w") do |file|
      index_file = File.read(File.join(template_root, html_path)).gsub(/\r/, '')
      doc = Hpricot(index_file)
      doc.search("##{content_id}").each { |elm| elm.inner_html = "<%= yield %>" }
      inside_yields.to_a.each do |name, css_path|
        doc.search(css_path).each do |elm|
          inside_yields_originals[name] = elm.inner_html.strip
          elm.inner_html = "<%= yield(:#{name}) %>"
        end
      end
      contents = doc.to_html
      contents.gsub!(%r{(["'])/?#{image_dir}}, '\1/images')
      contents.gsub!(%r{(["'])/?#{stylesheet_dir}}, '\1/stylesheets')
      contents.gsub!(%r{(["'])/?#{javascript_dir}}, '\1/javascripts')
      contents.sub!(%r{\s*</head>}, "\n  <%= yield(:head) %>\n</head>")
      file << contents
    end
  end

  def prepare_assets
    template_stylesheets.each do |file|
      File.open(File.join(template_temp_path, 'public/stylesheets', File.basename(file)), "w") do |f|
        contents = File.read(file)
        contents.gsub!(%r{url\((["']?)[./]*#{image_dir}}, 'url(\1/images')
        f << contents
      end
    end
    template_javascripts.each do |file|
      FileUtils.cp_r(file, File.join(template_temp_path, 'public/javascripts'))
    end
    template_images.each do |file|
      FileUtils.cp_r(file, File.join(template_temp_path, 'public/images'))
    end
  end
  
  def run_generator(options)
    # now use rubigen to install the files into the rails app
    # so users can get conflict resolution options from command line
    RubiGen::Base.reset_sources
    RubiGen::Base.prepend_sources(RubiGen::PathSource.new(:internal, File.dirname(__FILE__)))
    generator_options = options[:generator] || {}
    generator_options.merge!(:stdout => @stdout, :no_exit => true,
      :source => template_temp_path, :destination => rails_root)
    RubiGen::Scripts::Generate.new.run(["convert_theme"], generator_options)
  end

  def in_template_root(&block)
    FileUtils.chdir(template_root, &block)
  end
  
  def in_rails_root(&block)
    FileUtils.chdir(rails_root, &block)
  end

  def detect_template
    if detect_template_haml
      'haml'
    else
      'erb'
    end
  end
  
  def detect_template_haml
    in_rails_root do
      return true if File.exist?('vendor/plugins/haml')
      return true if File.exist?('config/environment.rb') && File.read('config/environment.rb') =~ /haml/
    end
  end
  
  def detect_stylesheet_dir
    if path = Dir[File.join(template_root, '**/*.css')].first
      File.dirname(path).gsub(template_root, '').gsub(%r{^/}, '')
    else
      'stylescheets'
    end
  end
  
  def detect_javascript_dir
    if path = Dir[File.join(template_root, '**/*.js')].first
      File.dirname(path).gsub(template_root, '').gsub(%r{^/}, '')
    else
      'javascripts'
    end
  end
  
  def detect_image_dir
    if path = Dir[File.join(template_root, '**/*.{jpg,png,gif}')].first
      File.dirname(path).gsub(template_root, '').gsub(%r{^/}, '')
    else
      'images'
    end
  end
  
  def template_stylesheets
    Dir[File.join(template_root, stylesheet_dir, '*')]
  end
  
  def template_javascripts
    Dir[File.join(template_root, javascript_dir, '*')]
  end

  def template_images
    Dir[File.join(template_root, image_dir, '*')]
  end
  
  def show_readme
    stdout.puts <<-README
    
    Your theme has been installed into your app.
    
    README
    stdout.puts "You are using named yields. Here are examples how to use them: "
    stdout.puts <<-EOS.gsub(/^    /, '')
    <% content_for :head do -%>
      <script>...</script>
    <% end -%>
    EOS
    inside_yields_originals.to_a.each do |key, original_contents|
      stdout.puts <<-EOS.gsub(/^      /, '')
      <% content_for :#{key} do -%>
        #{original_contents}
      <% end -%>
      EOS
    end
  end
end