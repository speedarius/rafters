require 'rafters/rspec/component_example_group'

if defined?(RSpec)
  RSpec.configure do |config|
    config.include(Rafters::ComponentExampleGroup, { type: :component, 
      example_group: { file_path: %r(spec/components) }
    })
  end
end
