class PostComponent
  include Rafters::Component

  # Settings
  setting :post, required: true
  setting :link_to_post, accepts: [true, false], default: false

  # Attributes
  attribute :post

  private

  def post
    @post ||= settings.post
  end
end
