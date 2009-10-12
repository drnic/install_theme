require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  include SetupThemeHelpers
  extend FileDiffMatcher
  
  context "bloganje theme to ERb using CSS path" do
    before(:all) { setup_bloganje }
    it { @theme.stylesheet_dir.should == "css" }
    it { @theme.image_dir.should == "img" }
    it { @theme.should be_erb }
    it { @theme.should be_valid }

    it_should_have_matching_file "app/views/layouts/application.html.erb"
    it_should_have_matching_file "app/views/layouts/_header.html.erb"
    it_should_have_matching_file "app/views/layouts/_sidebar.html.erb"
    it_should_have_matching_file "app/views/posts/show.html.erb"
    it_should_have_matching_file "app/helpers/template_helper.rb"
    it_should_have_matching_file "public/stylesheets/style.css"
    it_should_have_matching_file "public/stylesheets/theme.css"

    context "sample template /templates/index.html.erb" do
      subject do
        File.read(File.join(@target_application, 'app/views/original_template/index.html.erb'))
      end
      it { should include("<% content_for :head do -%>\n  <script></script>\n<% end -%>") }
      it { should include("<% content_for :header do -%>\n  My eCommerce Admin area\n<% end -%>") }
      it { should include('<div id="rightnow">') }
    end
    it "should create install_theme.yml containing the partial information" do
      expected = clean_file File.join(@template_root, "expected_install_theme.yml"), 'expected'
      actual   = clean_file File.join(@template_root, "install_theme.yml"), 'actual'
      diff = `diff #{expected} #{actual}  2> /dev/null`
      rputs diff unless diff.strip.empty?
      diff.strip.should == ""
    end
  end

  context "the-hobbit-website-template theme to ERb using xpath" do
    before(:all) { setup_hobbit }
    it { @theme.stylesheet_dir.should == "" }
    it { @theme.image_dir.should == "img" }
    it { @theme.should be_valid }

    it_should_have_matching_file "app/views/layouts/application.html.erb"
    it_should_have_matching_file "app/helpers/template_helper.rb"
    it_should_have_matching_file "public/stylesheets/default.css"
    
    it "should create install_theme.yml containing the partial information" do
      expected = clean_file File.join(@template_root, "expected_install_theme.yml"), 'expected'
      actual   = clean_file File.join(@template_root, "install_theme.yml"), 'actual'
      diff = `diff #{expected} #{actual}  2> /dev/null`
      rputs diff unless diff.strip.empty?
      diff.strip.should == ""
    end
  end

  context "use install_theme.yml for defaults" do
    before(:all) do
      setup_app_with_theme('bloganje', :setup_defaults => true)
    end
    it { File.should be_exist(File.join(@template_root, "install_theme.yml")) }
    it { @theme.content_path.should == "#content:text" }
    it { @theme.should be_valid }
    it_should_have_matching_file "app/views/layouts/application.html.erb"
    it_should_have_matching_file "app/views/layouts/_header.html.erb"
    it_should_have_matching_file "app/views/layouts/_sidebar.html.erb"
    it_should_have_matching_file "app/helpers/template_helper.rb"
    it_should_have_matching_file "public/stylesheets/style.css"
    it_should_have_matching_file "public/stylesheets/theme.css"
  end

  context "invalid if no content_path explicitly or via defaults file" do
    before(:all) { setup_bloganje(:content_path => nil) }
    it { @theme.content_path.should be_nil }
    it { @theme.should_not be_valid }
  end

  context "alternate layout file name" do
    before(:all) { setup_bloganje(:layout => "special") }
    it_should_have_matching_file "app/views/layouts/special.html.erb"
  end

end

