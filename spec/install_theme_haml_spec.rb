require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  include SetupThemeHelpers
  extend FileDiffMatcher

  context "bloganje theme to haml" do
    before(:all) { setup_bloganje :rails => {:haml => true} }
    it { @theme.should be_haml }
    it { @theme.should be_valid }

    it_should_have_matching_file "app/views/layouts/application.html.haml"
    it_should_have_matching_file "app/views/layouts/_header.html.haml"
    it_should_have_matching_file "app/views/layouts/_sidebar.html.haml"
    it_should_have_matching_file "app/helpers/template_helper.rb"
    it_should_have_matching_file "public/stylesheets/sass/style.sass"

    it { File.should be_exist(File.join(@target_application, "app/views/original_template/index.html.haml")) }
    context "sample template /original_template/index.html.haml" do
      subject do
        File.read(File.join(@target_application, 'app/views/original_template/index.html.haml'))
      end
      it { should include("- content_for :head do\n  %script") }
      it { should include("- content_for :header do\n  My eCommerce Admin area") }
      it { should include('#rightnow') }
    end
  end
end