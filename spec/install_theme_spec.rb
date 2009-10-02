require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  context "bloganje theme to ERb" do
    before(:all) do
      setup_base_rails
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
    it { @theme.stylesheet_dir.should == "css" }
    it { @theme.image_dir.should == "img" }
    it { @theme.should be_erb }

    %w[app/views/layouts/application.html.erb
      app/helpers/template_helper.rb
      public/stylesheets/style.css
      public/stylesheets/theme.css].each do |matching_file|
        it do
          expected = clean_file File.join(@expected_application, matching_file), 'expected'
          actual   = clean_file File.join(@target_application, matching_file), 'actual'
          diff = `diff #{expected} #{actual}  2> /dev/null`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end
    context "sample template /templates/index.html.erb" do
      subject do
        File.read(File.join(@target_application, 'app/views/original_template/index.html.erb'))
      end
      it { should include("<% content_for :head do -%>\n  <script></script>\n<% end -%>") }
      it { should include("<% content_for :header do -%>\n  My eCommerce Admin area\n<% end -%>") }
      it { should include('<div id="rightnow">') }
    end
  end

  context "the-hobbit-website-template theme to ERb" do
    before(:all) do
      setup_base_rails
      @stdout = stdout do |stdout|
        @theme = InstallTheme.new(
          :template_root => File.dirname(__FILE__) + "/fixtures/the-hobbit-website-template",
          :rails_root    => @target_application,
          :inside_yields => { :menu => '.navigation', :subtitle => '.header p' },
          :content_id    => "content", :stdout => stdout)
        @theme.apply_to_target(:generator => {:collision => :force, :quiet => true})
      end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/the-hobbit-website-template"
    end
    it { @theme.stylesheet_dir.should == "" }
    it { @theme.image_dir.should == "img" }

    %w[app/views/layouts/application.html.erb
      app/helpers/template_helper.rb
      public/stylesheets/default.css].each do |matching_file|
        it { File.should be_exist(File.join(@target_application, matching_file)) }
        it { File.should be_exist(File.join(@expected_application, matching_file)) }
        it do
          expected = clean_file File.join(@expected_application, matching_file), 'expected'
          actual   = clean_file File.join(@target_application, matching_file), 'actual'
          diff = `diff #{expected} #{actual}  2> /dev/null`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end
  end
end

