require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  context "bloganje theme to haml" do
    before do
      setup_base_rails :haml => true
      @stdout = stdout do |stdout|
        @theme = InstallTheme.new(:template_root => File.dirname(__FILE__) + "/fixtures/bloganje", 
          :rails_root    => @target_application,
          :content_id    => "content",
          :inside_yields => { :header => '#header h2', :sidebar => '#sidebar' },
          :stdout        => stdout)
        @theme.apply_to_target(:stdout => stdout, :generator => {:collision => :force, :quiet => true})
      end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/bloganje"
    end
    describe "becomes a Rails app with html templates" do
      it { @theme.should be_haml }
      it { File.should be_exist(File.join(@expected_application, "app/views/layouts/application.html.haml")) }
      it { File.should be_exist(File.join(@target_application, "app/views/layouts/application.html.haml")) }
      it { File.should_not be_exist(File.join(@target_application, "app/views/layouts/application.html.erb")) }
      it "should create app/views/layouts/application.html.erb as a layout file" do
        expected = clean_html(File.join(@expected_application, "app/views/layouts/application.html.haml"))
        actual   = clean_html(File.join(@target_application, "app/views/layouts/application.html.haml"))
        diff = `diff #{expected} #{actual}  2> /dev/null`
        rputs diff unless diff.strip.empty?
        diff.strip.should == ""
      end
      
      it { File.should be_exist(File.join(@target_application, "public/stylesheets/sass/style.sass")) }
      it { File.should be_exist(File.join(@expected_application, "public/stylesheets/sass/style.sass")) }
      it do
        expected = File.join(@expected_application, "public/stylesheets/sass/style.sass")
        actual   = File.join(@target_application, "public/stylesheets/sass/style.sass")
        diff = `diff #{expected} #{actual}  2> /dev/null`
        rputs diff unless diff.strip.empty?
        diff.strip.should == ""
      end
      it { @stdout.should include("- content_for :head do\n  %script") }
      it { @stdout.should include("- content_for :header do\n  My eCommerce Admin area") }
    end
  end
end