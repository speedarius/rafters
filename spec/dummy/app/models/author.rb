class Author
  attr_accessor :id, :name

  FIXTURES = [
    { id: 1, name: "Andrew Hite" },
    { id: 2, name: "Andrew Latimer" }
  ] 

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
  end

  class << self
    def all
      FIXTURES.map do |attributes|
        new(attributes)
      end
    end

    def find(id)
      attributes = FIXTURES.find { |fixture| fixture[:id] == id.to_i }
      new(attributes)
    end
  end
end
