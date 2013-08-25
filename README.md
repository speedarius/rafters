# Rafters

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'rafters'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rafters

## Usage

class TopicsComponent
  include Rafters::Component

  attribute :title
  attribute :topics
  attribute :page

  option :title, default: "Topics"
  option :type, default: "all"
  option :filter, default: "none"

  def title
    options.title
  end

  def topics
    Topic.where(type: options.type, filter: options.filter)
  end
end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
