require File.dirname(__FILE__) + '/spec_helper.rb'

describe InstallTheme do
  def replace_by_path(doc, path, replacement)
    InstallTheme.new.send(:replace_by_path, doc, path, replacement)
  end
  before(:each) do
    # @html = Nokogiri::HTML.parse(<<-HTML)
    @html = Hpricot(<<-HTML.gsub(/^    /, ''))
      <html>
      <body>
      <h1>Foo</h1>
      <p><span>The quick brown fox.</span></p>
      </body>
      </html>
    HTML
  end
  context "substituting <%= yield %>" do
    it "should access outer css paths - p" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <%= yield %>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, 'p', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
    it "should access outer css paths - p span" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <p><%= yield %></p>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, 'p span', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
    it "should access inner css paths - p" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <p><%= yield %></p>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, 'html p:text', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
    it "should access inner css paths - p span" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <p><span><%= yield %></span></p>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, 'html p span:text', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end

    it "should access outer xpaths" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <%= yield %>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, '//p', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
    it "should access output xpaths - p span" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <p><%= yield %></p>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, '//p/span', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
    it "should access inner xpaths - p" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <p><%= yield %></p>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, '//p/text()', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
    it "should access inner xpaths - p span" do
      expected = Hpricot(<<-HTML.gsub(/^      /, ''))
        <html>
        <body>
        <h1>Foo</h1>
        <p><span><%= yield %></span></p>
        </body>
        </html>
      HTML
      replaced = replace_by_path(@html, '//p/span/text()', '<%= yield %>')
      @html.to_html.should == expected.to_html
    end
  end
end