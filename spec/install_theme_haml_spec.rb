require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  include SetupThemeHelpers

  context "bloganje theme to haml" do
    before(:all) { setup_bloganje :rails => {:haml => true} }
    it { @theme.should be_haml }
    it { @theme.should be_valid }

    %w[app/views/layouts/application.html.haml
      app/views/layouts/_header.html.haml
      app/views/layouts/_sidebar.html.haml
      app/helpers/template_helper.rb
      public/stylesheets/sass/style.sass].each do |matching_file|
        it do
          expected = clean_file File.join(@expected_application, matching_file), 'expected'
          actual   = clean_file File.join(@target_application, matching_file), 'actual'
          diff = `diff #{expected} #{actual}  2> /dev/null`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end


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