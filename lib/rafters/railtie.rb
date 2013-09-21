require 'rafters/sprockets/directive_processor'

class Rafters::Railtie < Rails::Railtie
  initializer "rafters.load_view_paths" do |app|
    Rafters.view_paths = Dir[app.root.join("app", "components", "*", "views")]
  end

  initializer "rafters.load_asset_paths" do |app|
    Rafters.asset_paths = Dir[app.root.join("app", "components", "*", "assets", "*")]
  end

  initializer "rafters.set_asset_paths", :after => "rafters.load_asset_paths" do |app|
    app.config.assets.paths += Rafters.asset_paths
  end

  initializer "rafters.set_autoload_paths", :before => :set_autoload_paths do |app|
    app.config.autoload_paths += Dir[app.root.join("app", "components", "*", "*/")]
    app.config.autoload_paths += Dir[app.root.join("app", "components", "*/")]
  end

  config.after_initialize do |app|
    replace_preprocessor(app, 'text/css')
    replace_preprocessor(app, 'application/javascript')
  end

  private

  def replace_preprocessor(app, type)
    begin
      app.assets.unregister_preprocessor(type, Sprockets::DirectiveProcessor)
      app.assets.register_preprocessor(type, Rafters::DirectiveProcessor)
    rescue
      Rails.logger.warn("Could not load Sprockets::ComponentProcessor for #{type}")
    end
  end
end
