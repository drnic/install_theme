require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  def clean_stylesheet(contents, options = {})
    theme = InstallTheme.new({:image_dir => "img", :stylesheet_dir => "css"}.merge(options))
    theme.send(:clean_stylesheet, contents)
  end

  describe "fixing image urls" do
    it "should convert url('image.png') to url('/images/image.png')" do
      original = "background-image: url('image.png');"
      expected = "background-image: url('/images/image.png');"
      clean_stylesheet(original).should == expected
    end
    
    it "should convert url('image.png') to url('/images/image.png') if image and css dirs are both root" do
      original = "background-image: url('image.png');"
      expected = "background-image: url('/images/image.png');"
      clean_stylesheet(original, :image_dir => "", :stylesheet_dir => "").should == expected
    end
    
    it "should convert url(image.png) to url(/images/image.png)" do
      original = "background-image: url(image.png);"
      expected = "background-image: url(/images/image.png);"
      clean_stylesheet(original).should == expected
    end
    
    it 'should convert url("img/image.png") to url("/images/image.png")' do
      original = 'background-image: url("img/image.png");'
      expected = 'background-image: url("/images/image.png");'
      clean_stylesheet(original).should == expected
    end

    it "should convert url(/img/image.png) to url(/images/image.png)" do
      original = "background-image: url(/img/image.png);"
      expected = "background-image: url(/images/image.png);"
      clean_stylesheet(original).should == expected
    end

    it "should convert url(../img/image.png) to url(/images/image.png)" do
      original = "background-image: url(../img/image.png);"
      expected = "background-image: url(/images/image.png);"
      clean_stylesheet(original).should == expected
    end

    it "should convert url(css/iepngfix.htc) to url(/stylesheets/iepngfix.htc)" do
      original = "behavior: url(css/iepngfix.htc)"
      expected = "behavior: url(/stylesheets/iepngfix.htc)"
      clean_stylesheet(original).should == expected
    end

    it "should convert url(reset.css) to url(/stylesheets/reset.css)" do
      original = "behavior: url(reset.css)"
      expected = "behavior: url(/stylesheets/reset.css)"
      clean_stylesheet(original).should == expected
    end
  end
end