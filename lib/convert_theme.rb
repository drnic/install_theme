$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

class ConvertTheme
  VERSION = "0.0.1"
  
  def initialize(options = {})
    @template_root = File.expand_path(options[:template_root] || File.dirname('.'))
    @index_path    = options[:index_path] || "index.html"
  end
  
  def apply_to(rails_path, options = {})
    @rails_path = rails_path
    @template = (options[:template] || detect_template).to_s
  end
  
  def haml?
    @template == 'haml'
  end
  
  def erb?
    @template == 'erb'
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
    FileUtils.chdir(@rails_path) do
      return true if File.exist?('vendor/plugins/haml')
      return true if File.exist?('config/environment.rb') && File.read('config/environment.rb') =~ /haml/
    end
  end
end