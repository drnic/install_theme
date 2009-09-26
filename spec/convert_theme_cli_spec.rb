require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'convert_theme/cli'

describe ConvertTheme::CLI, "execute" do
  before(:each) do
    theme = stub
    ConvertTheme.should_receive(:new).
      with(:template_root => "path/to/app", 
        :content_id => "content_box",
        :index_path => "root.html",
        :template_type => "haml"
      ).
      and_return(theme)
    theme.should_receive(:apply_to).with(".")
    @stdout = stdout do |stdout_io|
      ConvertTheme::CLI.execute(stdout_io, %w[path/to/app . content_box
        --index_path=root.html
        --haml
      ])
    end
  end
  
  it("parses arguments and run generator") { }
end