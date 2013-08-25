class PostsComponent
  include Rafters::Component

  attribute :posts

  private

  def posts
    @posts ||= Post.all
  end
end
