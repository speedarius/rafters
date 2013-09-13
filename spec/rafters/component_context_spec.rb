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
      renderer.should_receive(:render).with(instance_of(FooComponent))
      controller.render_component(:foo, as: "foo")
    end

    context "with settings" do
      it "renders the provided component with the given settings" do
        FooComponent.should_receive(:new).with({ as: "foo", settings: { test: true } })
        controller.render_component(:foo, { as: "foo", settings: { test: true } })
      end
    end
  end
end
