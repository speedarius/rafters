class PostComponent
  include Rafters::Component

  # Settings
  setting :post
  setting :link_to_post, accepts: [true, false], default: false

  # Attributes
  attribute :post

  private

  def post
    @post ||= (settings.post || controller(:post))
  end
end
