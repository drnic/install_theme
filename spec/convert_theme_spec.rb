require File.dirname(__FILE__) + '/spec_helper.rb'

describe ConvertTheme do
  context "bloganje theme" do
    before do
      FileUtils.rm_rf(tmp_path)
      FileUtils.mkdir_p(tmp_path)
      FileUtils.chdir(tmp_path) do
      end
    end
    it "becomes a Rails app" do
      
    end
  end
end
