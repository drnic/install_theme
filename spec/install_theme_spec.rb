require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  context "bloganje theme to ERb using CSS path" do
    before(:all) do
      setup_base_rails
      @template_root = File.dirname(__FILE__) + "/fixtures/bloganje"
      FileUtils.rm_rf(File.join(@template_root, "install_theme.yml"))
      @stdout = stdout do |stdout|
        @theme = InstallTheme.new(:template_root => @template_root,
          :rails_root   => @target_application,
          :content_path => "#content",
          :partials     => { "header" => '#header h2', "sidebar" => '#sidebar' },
          :stdout       => stdout)
        @theme.apply_to_target(:stdout => stdout, :generator => {:collision => :force, :quiet => true})
      end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/bloganje"
    end
    it { @theme.stylesheet_dir.should == "css" }
    it { @theme.image_dir.should == "img" }
    it { @theme.should be_erb }

    %w[app/views/layouts/application.html.erb
      app/views/layouts/_header.html.erb
      app/views/layouts/_sidebar.html.erb
      app/helpers/template_helper.rb
      public/stylesheets/style.css
      public/stylesheets/theme.css].each do |matching_file|
        it "should having matching file #{matching_file}" do
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
    it "should create install_theme.yml containing the partial information" do
      expected = clean_file File.join(@template_root, "expected_install_theme.yml"), 'expected'
      actual   = clean_file File.join(@template_root, "install_theme.yml"), 'actual'
      diff = `diff #{expected} #{actual}  2> /dev/null`
      rputs diff unless diff.strip.empty?
      diff.strip.should == ""
    end
  end

  context "the-hobbit-website-template theme to ERb using xpath" do
    before(:all) do
      setup_base_rails
      @template_root = File.dirname(__FILE__) + "/fixtures/the-hobbit-website-template"
      FileUtils.rm_rf(File.join(@template_root, "install_theme.yml"))
      @stdout = stdout do |stdout|
        @theme = InstallTheme.new(:template_root => @template_root,
          :rails_root    => @target_application,
          :partials      => { "menu" => "//div[@class='navigation']", "subtitle" => "//div[@class='header']/p" },
          :content_path  => "//div[@class='content']", 
          :stdout        => stdout)
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
      setup_base_rails
      @template_root = File.dirname(__FILE__) + "/fixtures/bloganje"
      FileUtils.chdir(@template_root) do
        FileUtils.cp_r("expected_install_theme.yml", "install_theme.yml")
      end
      @stdout = stdout do |stdout|
        @theme = InstallTheme.new(:template_root => @template_root,
          :rails_root   => @target_application,
          :stdout       => stdout)
        @theme.apply_to_target(:stdout => stdout, :generator => {:collision => :force, :quiet => true})
      end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/bloganje"
    end
    it { File.should be_exist(File.join(@template_root, "install_theme.yml")) }
    it { @theme.content_path.should == "#content" }
    %w[app/views/layouts/application.html.erb
      app/views/layouts/_header.html.erb
      app/views/layouts/_sidebar.html.erb
      app/helpers/template_helper.rb
      public/stylesheets/style.css
      public/stylesheets/theme.css].each do |matching_file|
        it "should having matching file #{matching_file}" do
          expected = clean_file File.join(@expected_application, matching_file), 'expected'
          actual   = clean_file File.join(@target_application, matching_file), 'actual'
          diff = `diff #{expected} #{actual}  2> /dev/null`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end
  end
end

