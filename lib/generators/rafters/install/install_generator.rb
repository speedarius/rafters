class Rafters::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def create_initializer
    copy_file "initializer.rb", "config/initializers/rafters.rb"
  end

  def create_directories
    empty_directory "app/components"
  end

  def add_asset_requires
    inject_into_file "app/assets/stylesheets/application.css", after: "*= require_tree .\n" do <<-'RUBY'
 *= require_components`
    RUBY
    end

    inject_into_file "app/assets/javascripts/application.js", after: "//= require_tree .\n" do <<-'RUBY'
//= require_components
    RUBY
    end
  end
end
