module Rafters::Context
  extend ActiveSupport::Concern

  included do
    attr_accessor :rendered_components
    helper_method :rendered_components
    helper_method :render_component
    alias_method_chain :render, :component
  end

  def component_attributes(name, options = {})
    component = component(name, options)
    component.as_json
  end

  def render_component(name, options = {})
    component = component(name, options)
    component_renderer.render(component)
  end

  def render_with_component(*args, &block)
    if params[:component]
      component, settings = params[:component], params[:options]

      respond_to do |format|
        format.html { render_without_component(text: render_component(component, options)) }
        format.json { render_without_component(json: component_attributes(component, options)) }
      end
    else
      render_without_component(*args, &block)
    end
  end

  private

  def component_renderer
    @_component_renderer ||= Rafters::Renderer.new(self)
  end

  def component(name, options = {})
    component_klass = "#{name}_component".classify.constantize
    component = component_klass.new(options)
  end
end
