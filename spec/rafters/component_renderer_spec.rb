require 'spec_helper'

describe Rafters::ComponentRenderer do
  let(:view_context) { double("ViewContext").as_null_object }
  let(:controller) { double("Controller").as_null_object }

  before do
    view_context.stub(:render).and_return("<p>Output</p>")
    view_context.stub(:content_tag).and_yield
    controller.stub(:view_context).and_return(view_context)
  end

  describe "when initialized" do
    before do
      Rafters.stub(:view_paths).and_return(["/path/to/views"])
    end

    it "should add the view paths for all components to the controller" do
      controller.should_receive(:prepend_view_path).with("/path/to/views")
      Rafters::ComponentRenderer.new(controller)
    end
  end

  describe "#render" do
    subject { Rafters::ComponentRenderer.new(controller) }

    let(:component) { double("Component").as_null_object }

    before do
      component.stub(:attributes).and_return({ title: "Foo" })
      component.stub(:template_name).and_return("template")
    end

    it "renders the component template with it's settings and attributes" do
      view_context.should_receive(:render).with(file: "/template", locals: { title: "Foo" })
      subject.render(component)
    end
  end
end
