class Rafters::Source
  attr_accessor :component

  delegate :controller, :settings, to: :component

  def initialize(component)
    @component = component
  end
end
