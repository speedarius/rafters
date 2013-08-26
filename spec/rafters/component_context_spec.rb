require 'spec_helper'

class FooController < ActionController::Base
  include Rafters::ComponentContext
end

class FooComponent
  include Rafters::Component
end

describe Rafters::ComponentContext do
  let(:controller) { FooController.new }
  let(:renderer) { double("ComponentRenderer", render: "<p>Output</p>") }

  before do
    Rafters::ComponentRenderer.stub(:new).and_return(renderer)
  end

  describe "#render_component" do
    it "renders the provided component" do
      renderer.should_receive(:render).with(instance_of(FooComponent), nil)
      controller.render_component(:foo)
    end

    context "with settings" do
      it "renders the provided component with the given settings" do
        FooComponent.should_receive(:new).with({ test: true })
        controller.render_component(:foo, test: true)
      end
    end

    context "with a specified template name" do
      it "renders the provided component using the given template name" do
        renderer.should_receive(:render).with(instance_of(FooComponent), "template_name")
        controller.render_component(:foo, {}, "template_name")
      end
    end
  end
end
