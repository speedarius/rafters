module Rafters::ComponentExampleGroup
  extend ActiveSupport::Concern

  if defined?(ActionView::TestCase::Behavior)
    include ActionView::TestCase::Behavior
  end

  if defined?(RSpec::Rails)
    include RSpec::Rails::RailsExampleGroup
  end

  included do
    metadata[:type] = :component

    let(:identifier) { described_class.to_s.underscore }
    let(:options) { Hash.new }

    subject do
      described_class.new(identifier, options)
    end

    let(:renderer) do
      Rafters::Renderer.new(controller, controller.view_context)
    end

    let(:page) do
      Capybara.string renderer.render(subject)
    end

    before do
      subject.controller = controller
    end
  end
end
