class InstallTheme::Parsers::RailsForm
  attr_reader :inputs
  
  # Parses an HTML page and returns an Array of RailsForm objects
  # Each maps to a <form> tag, and #valid? returns true if a form
  # maps to a Ruby on Rails form.
  def self.parse(html)
    doc = Hpricot(html)
    doc.search('form').map { |form| self.new(form) }
  end
  
  def initialize(form_node)
    @form_node = form_node
    @inputs = @form_node.search('input[@type="text"],textarea').map { |input| parse_input(input) }
  end
  
  def valid?
    
  end
  
  protected
  def parse_input(input_node)
    input = OpenStruct.new(:field => nil, :helper => 'text_field', :value => nil, :render => "")
    input.helper = 'text_area' if input_node.name == 'textarea'
    input
  end
end