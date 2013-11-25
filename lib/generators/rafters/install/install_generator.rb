class Rafters::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_initializer
    copy_file "initializer.rb", "config/initializers/rafters.rb"
  end

  def create_directories
    empty_directory "app/components"
    empty_directory "spec/components" if defined?(RSpec)
  end
end
