module Rafters::Context
  extend ActiveSupport::Concern

  included do
    helper_method :render_component
    alias_method_chain :render, :component
  end

  def render_component(name, options = {})
    component = component(name, options)
    component_renderer.render(component)
  end

  def render_with_component(*args, &block)
    if params[:component]
      component, options = params[:component], params[:options].deep_dup

      respond_to do |format|
        format.html { render_without_component(text: render_component(component, options)) }
      end
    else
      render_without_component(*args, &block)
    end
  end

  def component_renderer
    @_component_renderer ||= Rafters::Renderer.new(self, view_context)
  end

  def component(name, options = {})
    component_klass = "#{name}_component".classify.constantize
    component_klass.new(options.delete(:as), options)
  end
end
