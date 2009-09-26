require 'optparse'

class ConvertTheme
  class CLI
    def self.execute(stdout, arguments=[])
      options = {}
      options[:template_root] = arguments.shift
      path_to_rails_app = arguments.shift
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Use any HTML template as a theme generator for your Rails app.

          Usage: #{File.basename($0)} path/to/template path/to/rails_app [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("--content_id=CONTENT_ID", String,
                "DOM id for the main DOM element for the <%= yield %>.",
                "Default: content") { |arg| options[:content_id] = arg }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)
      end
      unless options[:template_root] && path_to_rails_app
        stdout.puts parser; exit
      end
      ConvertTheme.new(options).apply_to(path_to_rails_app)
    end
  end
end