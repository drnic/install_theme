require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'convert_theme/cli'

describe ConvertTheme::CLI, "execute" do
  before(:each) do
    theme = stub
    ConvertTheme.should_receive(:new).
      with(:template_root => "path/to/app", 
        :content_id => "content_box",
        :index_path => "root.html",
        :template_type => "haml",
        :inside_yields => { :header => '#header h2', :sidebar => '#sidebar' }
      ).
      and_return(theme)
    theme.should_receive(:apply_to).with("path/to/rails_app")
    @stdout = stdout do |stdout_io|
      ConvertTheme::CLI.execute(stdout_io, %w[path/to/app path/to/rails_app content_box
        --index_path=root.html
        --haml
        --inside_yield=header=>#header\ h2
        --inside_yield=sidebar=>#sidebar
      ])
    end
  end
  
  it("parses arguments and run generator") { }
end