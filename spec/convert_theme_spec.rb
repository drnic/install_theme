require File.dirname(__FILE__) + '/spec_helper.rb'

describe ConvertTheme do
  context "bloganje theme to ERb" do
    before do
      setup_base_rails
      @theme = ConvertTheme.new(:template_root => File.dirname(__FILE__) + "/fixtures/bloganje")
      @theme.apply_to(@target_application)
      @expected_application = File.dirname(__FILE__) + "/expected/rails/bloganje"
    end
    it { @theme.should be_erb }
    describe "becomes a Rails app" do
      %w[app/views/layouts/application.html.erb].each do |matching_file|
        it do
          expected = clean_file(File.join(@expected_application, matching_file))
          actual   = File.join(@target_application, matching_file)
          diff = `diff #{expected} #{actual}`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end
      
    end
  end

  context "webresourcedepot theme to ERb" do
    before do
      setup_base_rails
      @theme = ConvertTheme.new(
        :template_root => File.dirname(__FILE__) + "/fixtures/webresourcedepot",
        :content_id => "center-column")
      @theme.apply_to(@target_application)
      @expected_application = File.dirname(__FILE__) + "/expected/rails/webresourcedepot"
    end
    it { @theme.should be_erb }
    describe "becomes a Rails app" do
      %w[app/views/layouts/application.html.erb].each do |matching_file|
        it do
          expected = clean_file(File.join(@expected_application, matching_file))
          actual   = File.join(@target_application, matching_file)
          diff = `diff #{expected} #{actual}`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end
      
    end
  end
end
