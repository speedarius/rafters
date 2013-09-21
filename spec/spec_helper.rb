require 'rubygems'
require 'spork'
require 'spork/ext/ruby-debug'

Spork.prefork do
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter 'spec/dummy'
    add_filter 'lib/rafters/railtie.rb'
  end

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../dummy/config/environment.rb", __FILE__)
  require 'rspec/rails'

  Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus
    config.order = 'random'
    config.expect_with :rspec do |c|
      c.syntax = :expect
    end
  end
end

Spork.each_run do
end
