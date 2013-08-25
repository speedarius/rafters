class Post
  attr_accessor :id, :title, :body, :author

  FIXTURES = [
    { id: 1, title: "Lorem Ipsum", body: "Lorem ipsum dolor sit amet...", author: Author.find(1) },
    { id: 2, title: "Dolor Sit Amet", body: "Consectetur adipiscing elit...", author: Author.find(2) }
  ] 

  def initialize(attributes = {})
    @id = attributes[:id]
    @title = attributes[:title]
    @body = attributes[:body]
    @author = attributes[:author]
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
