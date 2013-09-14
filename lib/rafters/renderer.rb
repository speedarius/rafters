class Rafters::Renderer
  def initialize(controller, view_context)
    @controller = controller
    @view_context = view_context

    Rafters.view_paths.each do |view_path|
      @controller.prepend_view_path(view_path)
    end
  end

  def render(component)
    component.controller = @controller

    @view_context.content_tag(:div, class: "component #{component.name.dasherize}", id: component.identifier) do
      @view_context.render(file: "/#{component.template_name}", locals: component.attributes)
    end
  end

  private

end
