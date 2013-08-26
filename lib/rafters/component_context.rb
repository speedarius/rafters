module Rafters::ComponentContext
  extend ActiveSupport::Concern

  included do
    helper_method :render_component
    alias_method_chain :render, :component
  end

  def render_component(name, settings = {}, template_name = nil)
    component_klass = "#{name}_component".classify.constantize
    component = component_klass.new(settings)
    component_renderer.render(component, template_name)
  end

  def render_component_attributes(name, settings = {})
    component_klass = "#{name}_component".classify.constantize
    component = component_klass.new(settings)
    { :"#{name}" => component.attributes }.as_json
  end

  def render_with_component(*args, &block)
    if params[:component]
      component, settings = params[:component], params[:settings]

      respond_to do |format|
        format.html do
          render_without_component(text: render_component(component, settings)) and return
        end

        format.json do
          render_without_component(json: render_component_attributes(component, settings)) and return
        end
      end
    else
      render_without_component(*args, &block)
    end
  end

  private

  def component_renderer
    @_component_renderer ||= Rafters::ComponentRenderer.new(self)
  end
end
