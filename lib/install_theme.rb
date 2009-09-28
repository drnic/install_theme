$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubigen'
require 'rubigen/scripts/generate'
require 'haml'
require 'haml/html'
require 'sass'
require 'sass/css'
require 'haml/exec'

class InstallTheme
  VERSION = "0.5.1"
  
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
    convert_to_haml('app/views/layouts/application.html.erb') if haml?
    prepare_sample_controller_and_view
    prepare_assets
    run_generator(options)
    show_readme
  end
  
  # This generator's templates folder is temporary
  # and is accessed via source_root within the generator.
  def template_temp_path
    @template_temp_path ||= begin
      template_path = File.join(tmp_dir, "install_theme", "templates")
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
    File.open(File.join(template_temp_path, layout_path), "w") do |f|
      index_file = File.read(File.join(template_root, html_path)).gsub(/\r/, '')
      doc = Hpricot(index_file)
      doc.search("##{content_id},.#{content_id}").each { |elm| elm.inner_html = "<%= yield %>" }
      inside_yields.to_a.each do |name, css_path|
        doc.search(css_path).each do |elm|
          inside_yields_originals[name] = elm.inner_html.strip
          elm.inner_html = "<%= yield(:#{name}) %>"
        end
      end
      contents = doc.to_html
      template_images.each do |file|
        image = File.basename(file)
        contents.gsub!(%r{(["'])/?[\w_\-\/]*#{image}}, '\1/images/' + image)
      end
      template_stylesheets.each do |file|
        stylesheet = File.basename(file)
        contents.gsub!(%r{(["'])/?[\w_\-\/]*#{stylesheet}}, '\1/stylesheets/' + stylesheet)
      end
      template_javascripts.each do |file|
        javascript = File.basename(file)
        contents.gsub!(%r{(["'])/?[\w_\-\/]*#{javascript}}, '\1/javascripts/' + javascript)
      end

      contents.gsub!(%r{(["'])/?#{image_dir}}, '\1/images') unless image_dir.blank?
      contents.gsub!(%r{(["'])/?#{stylesheet_dir}}, '\1/stylesheets') unless stylesheet_dir.blank?
      contents.gsub!(%r{(["'])/?#{javascript_dir}}, '\1/javascripts') unless javascript_dir.blank?

      contents.sub!(%r{\s*</head>}, "\n  <%= yield(:head) %>\n</head>")
      f << contents
    end
  end
  
  def convert_to_haml(path)
    from_path = File.join(template_temp_path, path)
    puts File.read(from_path)
    haml_path = from_path.gsub(/erb$/, "haml")
    html2haml(from_path, haml_path)
    puts File.read(haml_path)
    # only remove .erb if haml conversion successful
    # if File.size?(haml_path)
    #   FileUtils.rm_rf(from_path)
    # else
    #   FileUtils.rm_rf(haml_path)
    # end
  end

  def convert_to_sass(from_path)
    sass_path = from_path.gsub(/css$/, "sass").gsub(%r{public/stylesheets/}, 'public/stylesheets/sass/')
    FileUtils.mkdir_p(File.dirname(sass_path))
    css2sass(from_path, sass_path)
    FileUtils.rm_rf(from_path)
  end
  
  # The extracted chunks of HTML are retained in
  # app/views/original_template/index.html.erb (or haml)
  # wrapped in content_for blocks.
  #
  # Users can review this file for ideas of what HTML
  # works best in each section.
  def prepare_sample_controller_and_view
    FileUtils.chdir(template_temp_path) do
      FileUtils.mkdir_p("app/controllers")
      File.open("app/controllers/original_template_controller.rb", "w") { |f| f << <<-EOS.gsub(/^      /, '') }
      class OriginalTemplateController < ApplicationController
      end
      EOS

      FileUtils.mkdir_p("app/views/original_template")
      File.open("app/views/original_template/index.html.erb", "w") do |f|
        f << "<p>You are using named yields. Here are examples how to use them:</p>\n"
        f << show_content_for(:head, '<script></script>')
        inside_yields_originals.to_a.each do |key, original_contents|
          f << show_content_for(key, original_contents)
        end
      end
    end
    convert_to_haml('app/views/original_template/index.html.erb') if haml?
  end

  def prepare_assets
    template_stylesheets.each do |file|
      target_path = File.join(template_temp_path, 'public/stylesheets', File.basename(file))
      File.open(target_path, "w") do |f|
        contents = File.read(file)
        contents.gsub!(%r{url\((["']?)[./]*#{image_dir}}, 'url(\1/images')
        f << contents
      end
      convert_to_sass(target_path) if haml?
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
    RubiGen::Scripts::Generate.new.run(["install_theme"], generator_options)
  end
  
  # converts +from+ HTML into +to+ HAML
  # +from+ can either be file name, HTML content (String) or an Hpricot::Node
  # +to+ can either be a file name or an IO object with a #write method
  def html2haml(from, to)
    converter = Haml::Exec::HTML2Haml.new([])
    from = File.read(from) if File.exist?(from)
    to   = File.open(to, "w") unless to.respond_to?(:write)
    converter.instance_variable_set("@options", { :input => from, :output => to })
    converter.instance_variable_set("@module_opts", { :rhtml => true })
    converter.send(:process_result)
    to.close if to.respond_to?(:close)
  end

  def css2sass(from, to)
    converter = Haml::Exec::CSS2Sass.new([])
    from = File.read(from) if File.exist?(from)
    to   = File.open(to, "w") unless to.respond_to?(:write)
    converter.instance_variable_set("@options", { :input => from, :output => to })
    converter.instance_variable_set("@module_opts", { :rhtml => true })
    converter.send(:process_result)
    to.close if to.respond_to?(:close)
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
      'stylesheets'
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
    Dir[File.join(template_root, stylesheet_dir, '**/*.css')]
  end
  
  def template_javascripts
    Dir[File.join(template_root, javascript_dir, '**/*.js')]
  end

  def template_images
    Dir[File.join(template_root, image_dir, '**/*.{jpg,png,gif}')]
  end
  
  def show_readme
    stdout.puts <<-README
    
    Your theme has been installed into your app.
    
    README
  end
  
  def show_content_for(key, contents)
    # if haml?
    #   contents_file = File.join(tmp_dir, "partial.html")
    #   File.open(contents_file, "w") { |f| f << contents }
    #   haml_contents = `html2haml #{contents_file}`
    #   <<-EOS.gsub(/^      /, '')
    #   - content_for :#{key} do
    #     #{haml_contents}
    #   EOS
    # else
      <<-EOS.gsub(/^      /, '')
      <% content_for :#{key} do %>
        #{contents}
      <% end %>
      EOS
    # end
  end
  
  def tmp_dir
    ENV['TMPDIR'] || '/tmp'
  end
end