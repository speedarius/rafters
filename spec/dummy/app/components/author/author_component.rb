class AuthorComponent
  include Rafters::Component

  attribute :author

  setting :id

  private

  def author
    @author ||= Author.find(settings.id)
  end
end
