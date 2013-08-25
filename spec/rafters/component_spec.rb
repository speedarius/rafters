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

  describe ".setting" do
    it "adds the provided key to the component's settings" do
      HeadingComponent.setting(:type)

      heading = HeadingComponent.new
      heading.settings.should respond_to(:type)
    end

    context "with a :default value" do
      it "sets the setting's value to the provided value when no value is available" do
        HeadingComponent.setting(:type, default: "h1")

        heading = HeadingComponent.new
        heading.settings.type.should == "h1"
      end
    end

    context "with the :required option" do
      it "raises an error when accessing the settings if the value is nil" do
        HeadingComponent.setting(:type, required: true)

        heading = HeadingComponent.new
        -> { heading.settings }.should raise_error(Rafters::Component::SettingRequired)
      end
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
    before do
      HeadingComponent.setting(:type)
    end

    subject { HeadingComponent.new({ type: "h2" }) }

    it "returns the registered settings and their values" do
      subject.settings.should == Hashie::Mash.new({ type: "h2" })
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

  describe "#current" do
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
        subject.current(:foo_bar).should == "lorem ipsum"
      end
    end

    context "when referencing a method in the controller" do
      before do
        controller.singleton_class.send(:define_method, :lorem_ipsum, -> { "foo bar" })
      end

      it "returns the value of the method" do
        subject.current(:lorem_ipsum).should == "foo bar"
      end
    end

    context "when there is neither a method nor an instance variable with the given name in the controller" do
      it "raises an error" do
        -> { subject.current(:doesnt_exist) }.should raise_error(Rafters::Component::CurrentVariableOrMethodNameMissing)
      end
    end
  end

  after do
    # A little housekeeping after each spec runs, so that
    # we have fresh values for each class attribute
    HeadingComponent._attributes = nil
    HeadingComponent._settings = nil
    HeadingComponent._template_name = nil
  end
end
