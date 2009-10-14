class InstallTheme::Parsers::RailsForm
  attr_reader :inputs
  attr_reader :model
  
  # Parses an HTML page and returns an Array of RailsForm objects
  # Each maps to a <form> tag, and #valid? returns true if a form
  # maps to a Ruby on Rails form.
  def self.parse(html)
    doc = Hpricot(html)
    doc.search('form').map { |form| self.new(form) }
  end
  
  def initialize(form_node)
    @form_node = form_node
    parse_form_info
    @inputs = @form_node.search('input[@type="text"],textarea').map { |input| parse_input(input) }
  end
  
  def valid?
    model
  end
  
  def render
    if valid?
      "TODO"
    else
      @form_node.to_html
    end
  end
  
  protected
  def parse_form_info
    if @form_node.attributes['id'] =~ /new_(.*)$/
      @model = $1
      @request_action = 'new'
    elsif @form_node.attributes['id'] =~ /edit_(.*?)_(\d+?)$/
      @model = $1
      @request_action = 'edit'
      @model_id = $2
    end
  end
  
  def parse_input(input_node)
    input = OpenStruct.new(:field => nil, :helper => 'text_field', :value => nil, :render => "", :node => input_node)
    if input_node.attributes['name'] && input_node.attributes['name'] =~ /\[(.*?)\]$/
      input.field = $1
    end
    input.helper = 'text_area' if input_node.name == 'textarea'
    input.value = input_node.attributes['value']
    input.render = render_input(input)
    input
  end
  
  def render_input(input)
    if input.field
      options_list = []
      attributes = input.node.attributes.clone
      attributes.delete('id')
      attributes.delete('name')
      attributes.delete('type')
      for attribute in attributes.keys.sort
        options_list << ":#{attribute} => '#{input.node.attributes[attribute]}'"
      end
      options = options_list.empty? ? "" : ", " + options_list.join(', ')
      "<%= f.#{input.helper} :#{input.field}#{options} %>"
    else
      input.node.to_html # render normal HTML if form isn't rails form
    end
  end
  
  def render_header
    "<% form_for @#{model} do |f| %>"
  end
end