require 'spec_helper'
require 'rafters/railtie'

describe Rafters::DirectiveProcessor do
  subject { Sprockets::Environment.new }

  let(:asset_paths) do
    Rails.application.config.assets.paths
  end

  before do
    asset_paths.each do |path|
      subject.append_path(path)
    end
  end

  it "requires all component asset files" do
    subject.unregister_preprocessor('application/javascript', Sprockets::DirectiveProcessor)
    subject.register_preprocessor('application/javascript', Rafters::DirectiveProcessor)

    expect(subject['application.js'].to_s).to match(/var headingComponent = {};/)
  end
end
