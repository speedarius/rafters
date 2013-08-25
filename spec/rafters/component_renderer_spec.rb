require 'spec_helper'

describe Rafters::ComponentRenderer do
  let(:view_context) { double("ViewContext", render: "<p>Output</p>") }
  let(:controller) { double("Controller", prepend_view_path: true, view_context: view_context) }

  describe "when initialized" do
    before do
      Rafters.view_paths = ["/path/to/views"]
    end

    it "should add the view paths for all components to the controller" do
      controller.should_receive(:prepend_view_path).with("/path/to/views")
      Rafters::ComponentRenderer.new(controller)
    end
  end

  describe "#render" do
    subject { Rafters::ComponentRenderer.new(controller) }

    let(:component) do
      double("Component", attributes: { title: "Foo" }, :'controller=' => true, template_name: "template")
    end

    it "renders the component template with it's settings and attributes" do
      view_context.should_receive(:render).with(file: "/template", locals: { title: "Foo" })
      subject.render(component)
    end

    context "with a specified template name" do
      it "renders the component with the specified template" do
        view_context.should_receive(:render).with(file: "/custom_template", locals: { title: "Foo" })
        subject.render(component, "custom_template")
      end
    end
  end
end
