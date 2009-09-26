$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "hpricot"

class ConvertTheme
  VERSION = "0.0.1"
  
  attr_reader :template_root, :index_path, :rails_path, :template_type
  attr_reader :stylesheet_dir, :image_dir
  attr_reader :content_id
  
  def initialize(options = {})
    @template_root  = File.expand_path(options[:template_root] || File.dirname('.'))
    @index_path     = options[:index_path] || "index.html"
    @content_id     = options[:content_id] || "content"
    @stylesheet_dir = options[:stylesheet_dir] || detect_stylesheet_dir
    @image_dir      = options[:image_dir] || detect_image_dir
  end
  
  def apply_to(rails_path, options = {})
    @rails_path = rails_path
    @template_type = (options[:template_type] || detect_template).to_s

    File.open(File.join(rails_path, 'app/views/layouts/application.html.erb'), "w") do |file|
      index_file = File.read(File.join(template_root, index_path)).gsub(/\r/, '')
      doc = Hpricot(index_file)
      doc.search("##{content_id}").each do |div|
        div.inner_html = "<%= yield %>"
      end
      contents = doc.to_html
      contents.gsub!(%r{(["'])/?#{image_dir}}, '\1/images')
      contents.gsub!(%r{(["'])/?#{stylesheet_dir}}, '\1/stylesheets')
      file << contents
    end
    
    template_stylesheets.each do |file|
      FileUtils.cp(file, File.join(rails_path, 'public/stylesheets'))
    end
  end
  
  def haml?
    template_type == 'haml'
  end
  
  def erb?
    template_type == 'erb'
  end
  
  protected
  def in_template_root(&block)
    FileUtils.chdir(template_root, &block)
  end
  
  def in_rails_path(&block)
    FileUtils.chdir(rails_path, &block)
  end

  def detect_template
    if detect_template_haml
      'haml'
    else
      'erb'
    end
  end
  
  def detect_template_haml
    in_rails_path do
      return true if File.exist?('vendor/plugins/haml')
      return true if File.exist?('config/environment.rb') && File.read('config/environment.rb') =~ /haml/
    end
  end
  
  def detect_stylesheet_dir
    if path = File.dirname(Dir[File.join(template_root, '**/*.css')].first)
      path.gsub(template_root, '').gsub(%r{^/}, '')
    else
      'stylesheets'
    end
  end
  
  def detect_image_dir
    if path = File.dirname(Dir[File.join(template_root, '**/*.{jpg,png,gif}')].first)
      path.gsub(template_root, '').gsub(%r{^/}, '')
    else
      'images'
    end
  end
  
  def template_stylesheets
    Dir[File.join(template_root, stylesheet_dir, '*')]
  end
  
  def template_images
    Dir[File.join(template_root, image_dir, '*')]
  end
end