require File.dirname(__FILE__) + '/spec_helper.rb'

def setup_base_rails(options = {})
  tmp_path = File.dirname(__FILE__) + "/tmp"
  FileUtils.rm_rf(tmp_path)
  FileUtils.mkdir_p(tmp_path  )
  @target_application = File.join(tmp_path, "my_app")
  FileUtils.cp_r(File.dirname(__FILE__) + "/expected/rails/base_app", @target_application)
  `haml --rails #{@target_application}` if options[:haml]
end

describe ConvertTheme do
  context "bloganje theme to ERb" do
    before do
      setup_base_rails
      @theme = ConvertTheme.new(:template_root => File.dirname(__FILE__) + "/fixtures/bloganje")
      @theme.apply_to(@target_application)
    end
    it { @theme.should be_erb }
    describe "becomes a Rails app" do
      it { File.should be_exist("#{@target_application}/app/views/layouts/application.html.erb") }
    end
  end

  context "bloganje theme to HAML" do
    before do
      setup_base_rails(:haml => true)
      @theme = ConvertTheme.new(:template_root => File.dirname(__FILE__) + "/fixtures/bloganje")
      @theme.apply_to(@target_application)
    end
    it { @theme.should be_haml }
    describe "becomes a Rails app" do
      it { File.should be_exist("#{@target_application}/app/views/layouts/application.html.haml") }
    end
  end
end
