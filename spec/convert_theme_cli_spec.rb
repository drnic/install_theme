require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'convert_theme/cli'

def stdout(&block)
  stdout_io = StringIO.new
  yield stdout_io
  stdout_io.rewind
  stdout_io.read
end

describe ConvertTheme::CLI, "execute" do
  before(:each) do
    theme = stub
    ConvertTheme.should_receive(:new).
      with(:template_root => "path/to/app", :content_id => "content_box").
      and_return(theme)
    theme.should_receive(:apply_to).with(".")
    @stdout = stdout do |stdout_io|
      ConvertTheme::CLI.execute(stdout_io, ["path/to/app", ".", "--content_id=content_box"])
    end
  end
  
  it("parses arguments and run generator") { }
end