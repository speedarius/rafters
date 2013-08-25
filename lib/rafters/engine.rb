class Rafters::Engine < Rails::Engine
  isolate_namespace Rafters

  config.generators do |g|
    g.test_framework :rspec
    g.assets false
    g.helper false
  end

  initializer "rafters.load_view_paths", :after => "rafters.load_app_root" do |app|
    Rafters.view_paths = Dir[app.root.join("app", "components", "*", "views")]
  end

  initializer "rafters.set_autoload_paths", :before => :set_autoload_paths do |app|
    app.config.autoload_paths += Dir[app.root.join("app", "components", "*/")]
  end
end
