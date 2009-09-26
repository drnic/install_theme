begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'convert_theme'
Dir[File.dirname(__FILE__) + "/matchers/*.rb"].each { |matcher| require matcher }

# When running specs in TextMate, provide an rputs method to cleanly print objects into HTML display
# From http://talklikeaduck.denhaven2.com/2009/09/23/rspec-textmate-pro-tip
module Kernel
  if ENV.keys.find {|env_var| env_var.index("TM_") == 0}
    require "cgi"
    def rputs(*args)
      puts( *["<pre>", args.collect {|a| CGI.escapeHTML(a.to_s)}, "</pre>"])
    end
  else
    alias_method :rputs, :puts
  end
end

def clean_file(orig_file)
  tmp_dir = ENV['TMPDIR'] || '/tmp'
  file = File.join(tmp_dir, 'clean_file.html')
  File.open(file, "w") do |f|
    f << Hpricot(open(orig_file)).to_html
  end
  file
end

def setup_base_rails(options = {})
  tmp_path = File.dirname(__FILE__) + "/tmp"
  FileUtils.rm_rf(tmp_path)
  FileUtils.mkdir_p(tmp_path  )
  @target_application = File.join(tmp_path, "my_app")
  FileUtils.cp_r(File.dirname(__FILE__) + "/expected/rails/base_app", @target_application)
  `haml --rails #{@target_application}` if options[:haml]
  @target_application
end

