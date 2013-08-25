class Rafters::DirectiveProcessor < Sprockets::DirectiveProcessor
  def process_require_components_directive
    Rafters.asset_paths.sort.each do |asset_path|
      each_entry(asset_path) do |pathname|
        context.require_asset(pathname) if context.asset_requirable?(pathname)
      end
    end
  end
end
