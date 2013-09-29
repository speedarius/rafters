require 'rspec/rails'

module Rafters::ComponentExampleGroup
  extend ActiveSupport::Concern
  include RSpec::Rails::RailsExampleGroup

  included do
    metadata[:type] = :component

    controller do
      # Empty controller
    end

    let(:identifier) { described_class.to_s.underscore }
    let(:options) { Hash.new }

    subject do
      described_class.new(identifier, options).tap do |s|
        s.controller = controller
      end
    end

    let(:controller) do
      example.metadata[:controller].new.tap do |s|
        s.stub(:params).and_return({})
      end
    end

    let(:renderer) do
      Rafters::Renderer.new(controller, controller.view_context)
    end

    let(:page) do
      Capybara.string(renderer.render(subject))
    end
  end

  module ClassMethods
    def controller(base_class = nil, &body)
      base_class ||= ApplicationController

      metadata[:controller] = Class.new(base_class) do
        def self.name; "AnonymousController"; end
      end

      metadata[:controller].class_eval(&body)
    end
  end
end
