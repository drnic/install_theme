require 'optparse'

class InstallTheme
  class CLI
    def self.execute(stdout, arguments=[])
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Use any HTML template as a theme generator for your Rails app.
          
          Usage: #{File.basename($0)} path/to/rails_app path/to/template content_path [options]
          
            Examples of paths (CSS or XPath):
              * #header h2      - replaces the entire h2 element
              * #header h2:text - replaces the inner HTML of the h2 element
              * //div[@class='header']/h2        - replaces the entire h2 element
              * //div[@class='header']/h2/text() - replaces the inner HTML of the h2 element
          
          Options are:
        BANNER
        opts.separator ""
        opts.on("-p", "--partial KEY_AND_PATH", String,
                "Replace the inner HTML of an element with <%= yield :key %>",
                "See path examples above.") do |arg|
                  options[:partials] ||= {}
                  key, path = arg.split(/\s*:\s*/)[0..1]
                  if key && path
                    options[:partials][key.strip] = path.strip
                  else
                    stdout.puts partial_format_error(arg)
                    exit
                  end
                end
        opts.on("-l", "--layout application", String,
                "Set the layout file name.",
                "Layout files are stored in app/views/layouts and will be suffixed by .html.erb or .html.haml",
                "Default: application") { |arg| options[:layout] = arg }
        opts.on("-a", "--action posts/show", String,
                "Store content extracted from content_path into Rails action.",
                "Example, '-a posts/show' will create app/views/posts/show.html.erb file.",
                "Default: none") { |arg| options[:action] = arg }
        opts.on("--erb",
                "Generate ERb templates. Default: Yes, unless it's not.") { |arg| options[:template_type] = 'erb' }
        opts.on("--haml",
                "Generate HAML templates. Default: Auto-detect") { |arg| options[:template_type] = 'haml' }
        opts.on("--no-sass",
                "Don't generate sass files, just normal css. Default: false") { |arg| options[:no_sass] = true }
        opts.on("--index_path index.html", String,
                "HTML page to use for application layout.",
                "Default: index.html") { |arg| options[:index_path] = arg }
        opts.on("--defaults_file install_theme.yml", String,
                "Select an alternate YAML file containing defaults for the theme.",
                "Default: install_theme.yml") { |arg| options[:defaults_file] = arg }
        opts.on("-h", "--help",
                "Show this help message.") { |arg| stdout.puts opts; exit }
        opts.on("-v", "--version",
                "Show the version (which is #{InstallTheme::VERSION})."
                ) { |arg| stdout.puts InstallTheme::VERSION; exit }
        opts.parse!(arguments)
      end
      options[:rails_root]    = arguments.shift
      options[:template_root] = arguments.shift
      options[:content_path]  = arguments.shift
      theme = InstallTheme.new(options)
      unless theme.valid?
        stdout.puts parser; exit
      end
      theme.apply_to_target
    end
    
    def self.partial_format_error(partial_argument)
      <<-EOS.gsub(/^      /, '')
      ERROR: Incorrect format for --partial argument "#{partial_argument}".
      Correct format is: --partial label:path
      EOS
    end
  end
end
