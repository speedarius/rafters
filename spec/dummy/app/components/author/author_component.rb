class AuthorComponent
  include Rafters::Component

  # Attributes
  attribute :author

  private

  def author
    @author ||= Author.find(settings.id)
  end
end
