require File.dirname(__FILE__) + '/spec_helper.rb'

describe ConvertTheme do
  context "bloganje theme to ERb" do
    before do
      setup_base_rails
      stdout do |stdout|
        @theme = ConvertTheme.new(:template_root => File.dirname(__FILE__) + "/fixtures/bloganje", 
          :content_id => "content", 
          :stdout => stdout)
        @theme.apply_to(@target_application, :generator => {:collision => :force, :quiet => true})
      end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/bloganje"
    end
    it { @theme.should be_erb }
    it { @theme.stylesheet_dir.should == "css" }
    it { @theme.image_dir.should == "img" }
    describe "becomes a Rails app with html templates" do
      %w[app/views/layouts/application.html.erb].each do |matching_file|
        it { File.should be_exist(File.join(@target_application, matching_file)) }
        it { File.should be_exist(File.join(@expected_application, matching_file)) }
        it do
          expected = clean_file(File.join(@expected_application, matching_file))
          actual   = File.join(@target_application, matching_file)
          diff = `diff #{expected} #{actual}  2> /dev/null`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
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
    end
  end

  context "webresourcedepot theme to ERb" do
    before do
      setup_base_rails
        stdout do |stdout|
          @theme = ConvertTheme.new(
            :template_root => File.dirname(__FILE__) + "/fixtures/webresourcedepot",
            :content_id => "center-column", :stdout => $stdout)
          @theme.apply_to(@target_application, :generator => {:collision => :force, :quiet => true})
        end
      @expected_application = File.dirname(__FILE__) + "/expected/rails/webresourcedepot"
    end
    it { @theme.should be_erb }
    describe "becomes a Rails app" do
      %w[app/views/layouts/application.html.erb].each do |matching_file|
        it do
          expected = clean_file(File.join(@expected_application, matching_file))
          actual   = File.join(@target_application, matching_file)
          diff = `diff #{expected} #{actual}  2> /dev/null`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
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
