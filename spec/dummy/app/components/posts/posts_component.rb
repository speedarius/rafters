class PostsComponent
  include Rafters::Component

  attribute :posts

  private

  def posts
    @posts ||= current(:posts)
  end
end
