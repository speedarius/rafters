class Rafters::ComponentRenderer
  def initialize(controller)
    @controller = controller

    Rafters.view_paths.each do |view_path|
      @controller.prepend_view_path(view_path)
    end
  end

  def render(component, template_name = nil)
    component.controller = @controller

    template_name = (template_name || component.template_name)

    @controller.view_context.render({
      file: "/#{template_name}", 
      locals: component.attributes
    })
  end
end
