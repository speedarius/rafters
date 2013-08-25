class Rafters::Engine < Rails::Engine
  isolate_namespace Rafters

  config.generators do |g|
    g.test_framework :rspec
    g.assets false
    g.helper false
  end

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
    app.config.autoload_paths += Dir[app.root.join("app", "components", "*/")]
  end

  config.after_initialize do |app|
    app.assets.unregister_preprocessor('text/css', Sprockets::DirectiveProcessor)
    app.assets.register_preprocessor('text/css', Sprockets::ComponentProcessor)

    app.assets.unregister_preprocessor('application/javascript', Sprockets::DirectiveProcessor)
    app.assets.register_preprocessor('application/javascript', Sprockets::ComponentProcessor)
  end
end
