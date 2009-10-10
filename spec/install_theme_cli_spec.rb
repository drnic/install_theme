require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'install_theme/cli'

describe InstallTheme::CLI, "execute" do
  it("parses arguments and run generator") do
    theme = stub
    InstallTheme.should_receive(:new).
      with(:template_root => "path/to/template", 
        :rails_root       => "path/to/rails_app",
        :content_path     => "#content_box",
        :index_path       => "root.html",
        :template_type    => "haml",
        :partials         => { "header" => '#header h2', "sidebar" => '#sidebar' },
        :defaults_file    => "install_theme.yml",
        :layout           => "iphone"
      ).
      and_return(theme)
    theme.should_receive(:valid?).and_return(true)
    theme.should_receive(:apply_to_target)
    @stdout = stdout do |stdout_io|
      InstallTheme::CLI.execute(stdout_io, %w[path/to/rails_app path/to/template #content_box
        --index_path=root.html
        --haml
        --partial header:#header\ h2
        -p sidebar:#sidebar
        --defaults_file install_theme.yml
        --layout iphone
      ])
    end
  end

  it("allows for content_path and partials to be derived from defaults file") do
    theme = stub
    InstallTheme.should_receive(:new).
      with(:template_root => "path/to/template", 
        :rails_root       => "path/to/rails_app",
        :content_path     => nil
      ).
      and_return(theme)
    theme.should_receive(:valid?).and_return(true)
    theme.should_receive(:apply_to_target)
    @stdout = stdout do |stdout_io|
      InstallTheme::CLI.execute(stdout_io, %w[path/to/rails_app path/to/template])
    end
  end
  
  it "shows useful error message for poorly formatted --partial argument" do
    @stdout = stdout do |stdout_io|
      lambda do
        InstallTheme::CLI.execute(stdout_io, %w[path/to/rails_app path/to/template -p .just_dom])
      end.should raise_error(Exception)
    end
    @stdout.should =~ /incorrect format for --partial argument ".just_dom"/i
    @stdout.should =~ /correct format/i
    @stdout.should =~ /label:path/i
  end
end
