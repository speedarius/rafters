class PostComponent
  include Rafters::Component

  attribute :post

  setting :post
  setting :link_to_post

  private

  def post
    @post ||= settings.post
  end
end
