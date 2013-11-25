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
end
