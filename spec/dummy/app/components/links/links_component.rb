class LinksComponent < Rafters::Component

  # Attributes
  attribute :links

  private

  def links
    @links ||= [
      { name: "Google", url: "http://google.com" },
      { name: "Yahoo", url: "http://yahoo.com" },
      { name: "Bing", url: "http://bing.com" }
    ]
  end
end
