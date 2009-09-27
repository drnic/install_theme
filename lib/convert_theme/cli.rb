require 'optparse'

class ConvertTheme
  class CLI
    def self.execute(stdout, arguments=[])
      options = {}
      options[:template_root] = arguments.shift
      options[:rails_root]    = arguments.shift
      options[:content_id]    = arguments.shift
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Use any HTML template as a theme generator for your Rails app.

          Usage: #{File.basename($0)} path/to/template path/to/rails_app content_id [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("--haml",
                "Generate HAML templates.") { |arg| options[:template_type] = 'haml' }
        opts.on("--index_path=index.html", String,
                "HTML page to use for application layout.",
                "Default: index.html") { |arg| options[:index_path] = arg }
        opts.on("--inside_yield=KEY_AND_CSS_PATH", String,
                "Replace the inner HTML of an element with <%= yield :key %>",
                "Default: nil") do |arg|
                  options[:inside_yields] ||= {}
                  key, css_path = arg.split(/\s*=>\s*/)[0..1]
                  options[:inside_yields][key.strip.to_sym] = css_path.strip
                end
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)
      end
      unless options[:template_root] && options[:rails_root]
        stdout.puts parser; exit
      end
      ConvertTheme.new(options).apply_to_target
    end
  end
end