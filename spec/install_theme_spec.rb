require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  context "bloganje theme to ERb" do
    before do
      setup_base_rails
      stdout do |stdout|
        @theme = InstallTheme.new(:template_root => File.dirname(__FILE__) + "/fixtures/bloganje", 
          :rails_root    => @target_application,
          :content_id    => "content",
          :inside_yields => { :header => '#header h2', :sidebar => '#sidebar' },
          :stdout        => stdout)
      end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/bloganje"
    end
    it { @theme.stylesheet_dir.should == "css" }
    it { @theme.image_dir.should == "img" }
    it { @theme.should be_erb }
    describe "becomes a Rails app with html templates" do
      before do
        @stdout = stdout do |stdout|
          @theme.apply_to_target(:stdout => stdout, :generator => {:collision => :force, :quiet => true})
        end
      end
      it { File.should be_exist(File.join(@target_application, "app/views/layouts/application.html.erb")) }
      it { File.should be_exist(File.join(@expected_application, "app/views/layouts/application.html.erb")) }
      it "should create app/views/layouts/application.html.erb as a layout file" do
        expected = clean_file(File.join(@expected_application, "app/views/layouts/application.html.erb"))
        actual   = File.join(@target_application, "app/views/layouts/application.html.erb")
        diff = `diff #{expected} #{actual}  2> /dev/null`
        rputs diff unless diff.strip.empty?
        diff.strip.should == ""
      end
      
      %w[public/stylesheets/style.css
        public/stylesheets/theme.css].each do |matching_file|
          it { File.should be_exist(File.join(@target_application, matching_file)) }
          it { File.should be_exist(File.join(@expected_application, matching_file)) }
          it do
            expected = File.join(@expected_application, matching_file)
            actual   = File.join(@target_application, matching_file)
            diff = `diff #{expected} #{actual}  2> /dev/null`
            rputs diff unless diff.strip.empty?
            diff.strip.should == ""
          end
        end
      it { @stdout.should include("<% content_for :head do -%>\n  <script>...</script>\n<% end -%>") }
      it { @stdout.should include("<% content_for :header do -%>\n  My eCommerce Admin area\n<% end -%>") }
    end
  end

  context "webresourcedepot theme to ERb" do
    before do
      setup_base_rails
        @stdout = stdout do |stdout|
          @theme = InstallTheme.new(
            :template_root => File.dirname(__FILE__) + "/fixtures/webresourcedepot",
            :rails_root    => @target_application,
            :content_id    => "center-column", :stdout => stdout)
          @theme.apply_to_target(:generator => {:collision => :force, :quiet => true})
        end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/webresourcedepot"
    end
    describe "becomes a Rails app" do
      it "should create app/views/layouts/application.html.erb as a layout file" do
        expected = clean_file(File.join(@expected_application, "app/views/layouts/application.html.erb"))
        actual   = File.join(@target_application, "app/views/layouts/application.html.erb")
        diff = `diff #{expected} #{actual}  2> /dev/null`
        rputs diff unless diff.strip.empty?
        diff.strip.should == ""
      end
      
      %w[public/stylesheets/all.css].each do |matching_file|
          it { File.should be_exist(File.join(@target_application, matching_file)) }
          it { File.should be_exist(File.join(@expected_application, matching_file)) }
          it do
            expected = File.join(@expected_application, matching_file)
            actual   = File.join(@target_application, matching_file)
            diff = `diff #{expected} #{actual}  2> /dev/null`
            rputs diff unless diff.strip.empty?
            diff.strip.should == ""
          end
        end
    end
  end
end

