require 'rspec/rails'

module Rafters::ComponentExampleGroup
  extend ActiveSupport::Concern
  include RSpec::Rails::ViewExampleGroup

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
