class AuthorComponent < Rafters::Component

  # Attributes
  attribute :author

  setting :id, default: nil

  private

  def author
    @author ||= Author.find(settings.id)
  end
end
