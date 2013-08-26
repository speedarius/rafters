module Rafters::ComponentContext
  extend ActiveSupport::Concern

  included do
    attr_accessor :rendered_components
    helper_method :rendered_components
    helper_method :render_component
    alias_method_chain :render, :component
  end

  def component_attributes(name, settings = {})
    component = component(name, settings)
    component.as_json
  end

  def render_component(name, settings = {}, template_name = nil)
    component = component(name, settings)
    component_renderer.render(component, template_name)
  end

  def render_with_component(*args, &block)
    if params[:component]
      component, settings = params[:component], params[:settings]

      respond_to do |format|
        format.html { render_without_component(text: render_component(component, settings)) }
        format.json { render_without_component(json: component_attributes(component, settings)) }
      end
    else
      render_without_component(*args, &block)
    end
  end

  private

  def component_renderer
    @_component_renderer ||= Rafters::ComponentRenderer.new(self)
  end

  def component(name, settings = {})
    component_klass = "#{name}_component".classify.constantize
    component = component_klass.new(settings)
  end
end
