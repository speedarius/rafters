require 'active_support'
require 'hashie'

require 'rafters/railtie'

module Rafters
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Component
    autoload :Context
    autoload :Renderer
    autoload :Source
  end

  def self.setup
    yield self
  end

  mattr_accessor :view_paths
  @@view_paths = nil

  mattr_accessor :asset_paths
  @@asset_paths = nil
end

ActionController::Base.send(:include, Rafters::Context)
