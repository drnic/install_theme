require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'install_theme/cli'

describe InstallTheme::CLI, "execute" do
  before(:each) do
    theme = stub
    InstallTheme.should_receive(:new).
      with(:template_root => "path/to/app", 
        :rails_root       => "path/to/rails_app",
        :content_path     => "#content_box",
        :index_path       => "root.html",
        :template_type    => "haml",
        :partials         => { "header" => '#header h2', "sidebar" => '#sidebar' }
      ).
      and_return(theme)
    theme.should_receive(:apply_to_target)
    @stdout = stdout do |stdout_io|
      InstallTheme::CLI.execute(stdout_io, %w[path/to/app path/to/rails_app #content_box
        --index_path=root.html
        --haml
        --partial header:#header\ h2
        -p sidebar:#sidebar
      ])
    end
  end
  
  it("parses arguments and run generator") { }
end
