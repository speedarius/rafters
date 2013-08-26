require 'spec_helper'

class HeadingComponent
  include Rafters::Component
end

describe Rafters::Component do
  describe ".template_name" do
    it "set the component's template name to the provided value" do
      HeadingComponent.template_name("foo_bar_baz")
      HeadingComponent._template_name == "foo_bar_baz"
    end
  end

  describe ".attribute" do
    it "adds the provided method to the component's attributes" do
      HeadingComponent.send(:define_method, :title, -> { "Lorem Ipsum" })
      HeadingComponent.attribute(:title)

      heading = HeadingComponent.new
      heading.attributes.should have_key(:title)
    end
  end

  describe ".attributes" do
    it "adds a list of methods to the components attributes" do
      HeadingComponent.send(:define_method, :title, -> { "Lorem Ipsum" })
      HeadingComponent.send(:define_method, :subtitle, -> { "Dolor Sit Amet" })
      HeadingComponent.attributes(:title, :subtitle)

      heading = HeadingComponent.new
      heading.attributes.keys.map(&:to_sym).should include(:title)
      heading.attributes.keys.map(&:to_sym).should include(:subtitle)
    end
  end

  describe ".defaults" do
    it "adds default values to the component settings" do
      HeadingComponent.defaults(foo: "bar")

      heading = HeadingComponent.new
      heading.settings.foo.should == "bar"
    end
  end

  describe "#attributes" do
    before do
      HeadingComponent.send(:define_method, :title, -> { "Lorem Ipsum" })
      HeadingComponent.attribute(:title)
    end

    subject { HeadingComponent.new }

    it "returns the registered attributes and their values" do
      subject.attributes.should == Hashie::Mash.new({ title: "Lorem Ipsum", settings: {} })
    end
  end

  describe "#settings" do
    subject { HeadingComponent.new({ type: "h2" }) }

    it "returns the provided settings" do
      subject.settings.should == Hashie::Mash.new({ type: "h2" })
    end

    it "gives provided settings precedence over default settings" do
      HeadingComponent.default(:type, "h1")
      subject.settings[:type].should == "h2"
    end
  end

  describe "#template_name" do
    subject { HeadingComponent.new }

    context "with no specified template name" do
      it "returns the inferred template name" do
        subject.template_name.should == "heading_component"
      end
    end

    context "with a specified template name" do
      context "(string / symbol)" do
        before do
          HeadingComponent.stub(:_template_name).and_return("foo_bar_baz")
        end

        it "returns the specified template name" do
          subject.template_name.should == "foo_bar_baz"
        end
      end

      context "(proc)" do
        before do
          HeadingComponent.send(:define_method, :foo_bar, -> { "foo_bar_bacon" })
          HeadingComponent.stub(:_template_name).and_return(lambda { |c| c.foo_bar })
        end

        it "calls the proc and returns the stringified result" do
          subject.template_name.should == "foo_bar_bacon"
        end
      end
    end
  end

  describe "#controller" do
    subject { HeadingComponent.new }

    let(:controller) { Object.new }

    before do
      subject.controller = controller
    end

    context "when referencing an instance variable in the controller" do
      before do
        controller.instance_variable_set("@foo_bar", "lorem ipsum")
      end

      it "returns the value of the instance variable" do
        subject.controller(:foo_bar).should == "lorem ipsum"
      end
    end

    context "when referencing a method in the controller" do
      before do
        controller.singleton_class.send(:define_method, :lorem_ipsum, -> { "foo bar" })
      end

      it "returns the value of the method" do
        subject.controller(:lorem_ipsum).should == "foo bar"
      end
    end

    context "when there is neither a method nor an instance variable with the given name in the controller" do
      it "raises an error" do
        -> { subject.controller(:doesnt_exist) }.should raise_error(Rafters::Component::ControllerMethodOrVariableMissing)
      end
    end
  end

  after do
    # A little housekeeping after each spec runs, so that
    # we have fresh values for each class attribute
    HeadingComponent._attributes = [:settings]
    HeadingComponent._defaults = {}
    HeadingComponent._template_name = nil
  end
end
