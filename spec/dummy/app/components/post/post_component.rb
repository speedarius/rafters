class PostComponent < Rafters::Component

  attribute :post

  setting :post, default: nil

  private

  def post
    @post ||= (settings.post || controller(:post))
  end
end
