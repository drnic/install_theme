require File.dirname(__FILE__) + '/spec_helper.rb'

def clean_file(file)
  file
end

def setup_base_rails(options = {})
  tmp_path = File.dirname(__FILE__) + "/tmp"
  FileUtils.rm_rf(tmp_path)
  FileUtils.mkdir_p(tmp_path  )
  @target_application = File.join(tmp_path, "my_app")
  FileUtils.cp_r(File.dirname(__FILE__) + "/expected/rails/base_app", @target_application)
  `haml --rails #{@target_application}` if options[:haml]
  @target_application
end

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
          diff = `diff #{expected} #{File.join(@target_application, matching_file)}`
          rputs diff unless diff.strip.empty?
          diff.strip.should == ""
        end
      end
      
    end
  end
end
