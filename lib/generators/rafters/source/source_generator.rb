class Rafters::SourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)
  argument :source_name, type: :string

  def create_directory
    empty_directory "#{base_directory}"
  end

  def create_files
    template "source.rb.erb", "#{base_directory}/#{source_file_name}_source.rb"
  end

  private

  def base_directory
    "app/components/#{file_name}/sources"
  end

  def source_file_name
    source_name.underscore
  end

  def source_class_name
    source_name.classify
  end
end
