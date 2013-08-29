class Rafters::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_initializer
    copy_file "initializer.rb", "config/initializers/rafters.rb"
  end

  def create_directories
    empty_directory "app/components"
  end

  def add_asset_requires
    say_status("[instructions]", "Please add //= require_components to your application.css and application.js files")
  end
end
