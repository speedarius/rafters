class PostsComponent
  include Rafters::Component

  attribute :posts

  private

  def posts
    @posts ||= controller(:posts)
  end
end
