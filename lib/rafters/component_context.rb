module Rafters::ComponentContext
  extend ActiveSupport::Concern

  included do
    helper_method :render_component
  end

  def render_component(name, settings = {}, template_name = nil)
    component_klass = "#{name}_component".classify.constantize
    component = component_klass.new(settings)
    component_renderer.render(component, template_name)
  end

  private

  def component_renderer
    @_component_renderer ||= Rafters::ComponentRenderer.new(self)
  end
end
