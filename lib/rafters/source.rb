module Rafters::Source
  extend ActiveSupport::Concern

  included do
    attr_accessor :component

    delegate :controller, :settings, to: :component
  end

  def initialize(component)
    @component = component
  end
end
