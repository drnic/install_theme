require 'optparse'

class InstallTheme
  class CLI
    def self.execute(stdout, arguments=[])
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Use any HTML template as a theme generator for your Rails app.
          
          Usage: #{File.basename($0)} path/to/template path/to/rails_app content_path [options]
          
          Options are:
        BANNER
        opts.separator ""
        opts.on("--defaults_file install_theme.yml", String,
                "Select an alternate YAML file containing defaults for the theme.",
                "Default: install_theme.yml") { |arg| options[:defaults_file] = arg }
        opts.on("--erb",
                "Generate ERb templates.",
                "Default: auto-detect") { |arg| options[:template_type] = 'erb' }
        opts.on("--haml",
                "Generate HAML templates.",
                "Default: auto-detect") { |arg| options[:template_type] = 'haml' }
        opts.on("--index_path index.html", String,
                "HTML page to use for application layout.",
                "Default: index.html") { |arg| options[:index_path] = arg }
        opts.on("-p", "--partial KEY_AND_PATH", String,
                "Replace the inner HTML of an element with <%= yield :key %>",
                "Example using CSS path: --partial header:#header",
                "Example using XPath: --partial \"header://div[@id='header']\"") do |arg|
                  options[:partials] ||= {}
                  key, css_path = arg.split(/\s*:\s*/)[0..1]
                  options[:partials][key.strip] = css_path.strip
                end
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
  end
end
