class Rafters::ComponentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def create_directories
    empty_directory "#{base_directory}"
    empty_directory "#{base_directory}/assets"
    empty_directory "#{base_directory}/assets/javascripts"
    empty_directory "#{base_directory}/assets/stylesheets"
    empty_directory "#{base_directory}/assets/images"
    empty_directory "#{base_directory}/sources"
    empty_directory "#{base_directory}/views"
  end

  def create_gitkeeps
    create_file "#{base_directory}/assets/images/.gitkeep"
  end

  def create_files
    template "component.rb.erb", "#{base_directory}/#{file_name}_component.rb"
    template "assets/javascripts/component.js.erb", "#{base_directory}/assets/javascripts/#{file_name}_component.js"
    template "assets/stylesheets/component.scss.erb", "#{base_directory}/assets/stylesheets/#{file_name}_component.scss"
    template "views/component.html.erb", "#{base_directory}/views/#{file_name}_component.html.erb"
  end

  private

  def base_directory
    "app/components/#{file_name}"
  end
end
