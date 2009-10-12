require 'rubygems'
require 'spec'
require 'hpricot'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'install_theme'
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

def clean_html(orig_file, scope)
  tmp_dir = ENV['TMPDIR'] || '/tmp'
  file = File.join(tmp_dir, "#{scope}_clean_html.html")
  File.open(file, "w") do |f|
    f << Hpricot(open(orig_file)).to_html
  end
  file
end

def clean_file(orig_file, scope)
  return clean_html(orig_file, scope) if orig_file =~ /html/
  tmp_dir = ENV['TMPDIR'] || '/tmp'
  file = File.join(tmp_dir, "#{scope}_clean_html.html")
  File.open(file, "w") do |f|
    f << File.open(orig_file).readlines.map {|line| line.strip}.join("\n")
  end
  file
end

def stdout(&block)
  stdout_io = StringIO.new
  yield stdout_io
  stdout_io.rewind
  stdout_io.read
end

module FileDiffMatcher
  def it_should_have_matching_file(matching_file)
    it "should having matching file #{matching_file}" do
      expected = clean_file File.join(@expected_application, matching_file), 'expected'
      actual   = clean_file File.join(@target_application, matching_file), 'actual'
      diff = `diff #{expected} #{actual}  2> /dev/null`
      rputs diff unless diff.strip.empty?
      diff.strip.should == ""
    end
  end
end

module SetupThemeHelpers
  def setup_app_with_theme(theme, theme_options = {})
    setup_base_rails(theme_options.delete(:rails) || {})
    @template_root = File.join(File.dirname(__FILE__), "fixtures", theme)
    FileUtils.chdir(@template_root) do
      if theme_options.delete(:setup_defaults)
        FileUtils.cp_r("expected_install_theme.yml", "install_theme.yml")
      else
        FileUtils.rm_rf("install_theme.yml")
      end
    end
    @stdout = stdout do |stdout|
      @theme = InstallTheme.new({:template_root => @template_root,
        :rails_root   => @target_application,
        :stdout       => stdout}.merge(theme_options))
      @theme.apply_to_target(:stdout => stdout, :generator => {:collision => :force, :quiet => true})
    end
    @expected_application = File.join(File.dirname(__FILE__), "expected/rails", theme)
  end

  def setup_bloganje(theme_options = {})
    setup_app_with_theme('bloganje', {
      :content_path => "#content:text", 
      :partials => { "header" => '#header h2 text()', "sidebar" => '#sidebar' },
      :action => "posts/show"
    }.merge(theme_options))
  end
  
  def setup_hobbit(theme_options = {})
    setup_app_with_theme('the-hobbit-website-template', {
      :content_path  => "//div[@class='content']/text()",
      :partials      => { "menu" => "//div[@class='navigation']/text()", "subtitle" => "//div[@class='header']/p" }
    }.merge(theme_options))
  end

  def setup_base_rails(options)
    tmp_path = File.dirname(__FILE__) + "/tmp"
    FileUtils.rm_rf(tmp_path)
    FileUtils.mkdir_p(tmp_path  )
    @target_application = File.join(tmp_path, "my_app")
    FileUtils.cp_r(File.dirname(__FILE__) + "/expected/rails/base_app", @target_application)
    `haml --rails #{@target_application}` if options[:haml]
    @target_application
  end
end
  