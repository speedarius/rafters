class HeadingComponent
  include Rafters::Component

  attribute :title

  setting :level, required: true

  private

  def title
    current(:title)
  end
end
