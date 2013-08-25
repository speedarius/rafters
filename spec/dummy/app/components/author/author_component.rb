class AuthorComponent
  include Rafters::Component

  # Settings
  setting :id, required: true

  # Attributes
  attribute :author

  private

  def author
    @author ||= Author.find(settings.id)
  end
end
