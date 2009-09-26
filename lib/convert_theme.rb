$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "hpricot"

class ConvertTheme
  VERSION = "0.0.1"
  
  attr_reader :template_root, :index_path, :rails_path, :template_type
  attr_reader :content_id
  
  def initialize(options = {})
    @template_root = File.expand_path(options[:template_root] || File.dirname('.'))
    @index_path    = options[:index_path] || "index.html"
    @content_id    = options[:content_id] || "content"
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
      file << doc.to_html
    end
  end
  
  def haml?
    template_type == 'haml'
  end
  
  def erb?
    template_type == 'erb'
  end
  
  protected
  def detect_template
    if detect_template_haml
      'haml'
    else
      'erb'
    end
  end
  
  def detect_template_haml
    FileUtils.chdir(rails_path) do
      return true if File.exist?('vendor/plugins/haml')
      return true if File.exist?('config/environment.rb') && File.read('config/environment.rb') =~ /haml/
    end
  end
end