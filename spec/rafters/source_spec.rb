require 'spec_helper'

describe Rafters::Source do
  let(:component) { Rafters::Component.new("heading") }
  subject { Rafters::Source.new(component) }

  it { should delegate(:controller).to(:component) }
  it { should delegate(:settings).to(:component) }
end
