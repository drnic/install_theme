module TemplateHelper
  def render_or_default(partial, default = partial)
    render :partial => partial
  rescue ActionView::MissingTemplate
    begin
      render :partial => "layouts/#{default}"
    rescue ActionView::MissingTemplate
      nil
    end
  end
end