class PostComponent
  include Rafters::Component

  attribute :post

  private

  def post
    @post ||= (settings.post || controller(:post))
  end
end
