require 'spec_helper'

describe Rafters::Component do
  before do
    Object.send(:remove_const, 'HeadingComponent') if defined?(HeadingComponent)
    class HeadingComponent < Rafters::Component; end
  end

  let(:controller) do 
    double("Controller", params: {})
  end

  subject do 
    component = HeadingComponent.new("heading")
    component.controller = controller
    component
  end

  describe "#options" do
    it "replaces proc values with their result" do
      HeadingComponent.option :wrapper, lambda { |component| component.is_a?(Rafters::Component) }
      subject.options.wrapper.should === true
    end

    it "replaces truthy string values with boolean true" do
      HeadingComponent.option :wrapper, "true"
      subject.options.wrapper.should === true
    end

    it "replaces falsey string values with boolean false" do
      HeadingComponent.option :wrapper, "false"
      subject.options.wrapper.should === false
    end

    context "with default options" do
      before do
        HeadingComponent.option :view_name, "heading_component"
      end

      it "returns the default values for those options" do
        subject.options.view_name.should == "heading_component"
      end

      context "and local options" do
        before do
          subject.local_options = { view_name: "foo_component" }
        end

        it "returns the local values for those options" do
          subject.options.view_name.should == "foo_component"
        end
      end

      context "and param options" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { view_name: "baz_component" } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those options" do
          subject.options.view_name.should == "baz_component"
        end
      end
    end

    context "with local options" do
      before do
        subject.local_options = { view_name: "lipsum_component" }
      end

      it "returns the locally defined values for those options" do
        subject.options.view_name.should == "lipsum_component"
      end

      context "and param options" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { view_name: "dolor_component" } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those options" do
          subject.options.view_name.should == "dolor_component"
        end
      end
    end

    context "with param options" do
      let(:params) do
        HashWithIndifferentAccess.new({ heading: { view_name: "bacon_component" } })
      end

      before do
        controller.stub(:params).and_return(params)
      end

      it "returns the param values for those options" do
        subject.options.view_name.should == "bacon_component"
      end
    end
  end

  describe "#settings" do
    it "replaces proc values with their result" do
      HeadingComponent.setting :title, default: lambda { |component| component.class.name.titleize }
      subject.settings.title.should === "Heading Component"
    end

    it "replaces truthy string values with boolean true" do
      HeadingComponent.setting :published, default: "true"
      subject.settings.published.should === true
    end

    it "replaces falsey string values with boolean false" do
      HeadingComponent.setting :published, default: "false"
      subject.settings.published.should === false
    end

    context "with required settings" do
      before do
        HeadingComponent.setting :title, required: true
      end

      it "raises an error if the required setting is nil" do
        -> { subject.settings }.should raise_error(Rafters::Component::SettingRequired)
      end

      it "does not raise an error if the required setting is not nil" do
        subject.local_settings[:title] = "Foo Bar"
        -> { subject.settings }.should_not raise_error(Rafters::Component::SettingRequired)
      end
    end

    context "with default settings" do
      before do
        HeadingComponent.setting :title, default: "Heading Component"
      end

      it "returns the default values for those settings" do
        subject.settings.title.should == "Heading Component"
      end

      context "and local settings" do
        before do
          subject.local_settings = { title: "Foo Heading" }
        end

        it "returns the local values for those settings" do
          subject.settings.title.should == "Foo Heading"
        end
      end

      context "and param settings" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { settings: { title: "Baz Component" } } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those settings" do
          subject.settings.title.should == "Baz Component"
        end
      end
    end

    context "with local settings" do
      before do
        subject.local_settings = { title: "Lorem Component" }
      end

      it "returns the locally defined values for those settings" do
        subject.settings.title.should == "Lorem Component"
      end

      context "and param settings" do
        let(:params) do
          HashWithIndifferentAccess.new({ heading: { settings: { title: "Dolor Component" } } })
        end

        before do
          controller.stub(:params).and_return(params)
        end

        it "returns the param values for those settings" do
          subject.settings.title.should == "Dolor Component"
        end
      end
    end

    context "with param settings" do
      let(:params) do
        HashWithIndifferentAccess.new({ heading: { settings: { title: "Bacon Component" } } })
      end

      before do
        controller.stub(:params).and_return(params)
      end

      it "returns the param values for those settings" do
        subject.settings.title.should == "Bacon Component"
      end
    end
  end

  describe "#attributes" do
    before do
      HeadingComponent.send(:define_method, :title, -> { "Heading Component" })
      HeadingComponent.attribute :title
    end

    it "returns the values of defined attributes" do
      subject.attributes.title.should == "Heading Component"
    end
  end

  describe "#source" do
    before do
      class FooSource < Rafters::Source; end
      subject.local_options = { source_name: "FooSource" }
    end

    it "returns an instance of the provided source name's class" do
      subject.source.should be_an_instance_of(FooSource)
    end

    it "should set the source's component delegate to itself" do
      subject.source.component.should == subject
    end
  end

  describe "#locals" do
    before do
      HeadingComponent.send(:define_method, :title, -> { "Heading Component" })
      HeadingComponent.attribute(:title)
      HeadingComponent.setting(:foo, default: "bar")
    end

    it "includes all defined attributes for the component" do
      subject.locals[:title].should == "Heading Component"
    end

    it "includes settings for the component" do
      subject.locals[:settings].should == Hashie::Mash.new(foo: "bar")
    end

    it "includes the component" do
      subject.locals[:component].should == subject
    end
  end

  describe "#as_json" do
    before do
      HeadingComponent.option(:source_name, "FooSource")
      HeadingComponent.setting(:foo, default: "bar")
    end

    it "includes the component's identifier" do
      subject.as_json["identifier"].should == subject.identifier
    end

    it "includes the component's options" do
      subject.as_json["options"].should == Hashie::Mash.new(source_name: "FooSource", view_name: "heading_component", wrapper: true)
    end

    it "includes the component's settings" do
      subject.as_json["settings"].should == Hashie::Mash.new(foo: "bar")
    end
  end

  describe "#controller" do
    context "when the argument is an instance variable in the controller" do
      before do
        controller.instance_variable_set("@foo", "bar")
      end

      it "returns the instance variable's value" do
        subject.controller(:foo).should == "bar"
      end
    end

    context "when the argument is an instance method in the controller" do
      before do
        controller.stub(:bar).and_return("baz")
      end

      it "returns the instance method's value" do
        subject.controller(:bar).should == "baz"
      end
    end

    context "when the argument is not defined in the controller" do
      it "returns nil" do
        subject.controller(:baz).should == nil
      end
    end
  end

  describe "when subclassed" do
    before do
      class FooComponent < Rafters::Component; end
    end

    it "sets the default wrapper option" do
      FooComponent._options[:wrapper].should == true
    end

    it "sets the default view_name option" do
      FooComponent._options[:view_name].should == "foo_component"
    end

    it "sets the default source_name option" do
      FooComponent._options[:source_name] == nil
    end
  end

  describe ".setting" do
    before do
      HeadingComponent.setting(:published)
    end

    it "adds the provided setting name to the list of available settings" do
      subject.settings.keys.should include("published")
    end

    context "when provided a default" do
      before do
        HeadingComponent.setting(:archived, default: false)
      end

      it "adds the default to the list of default settings" do
        subject.settings.archived.should == false
      end
    end
  end

  describe ".attribute" do
    before do
      HeadingComponent.send(:define_method, :foo, -> { "bar" })
      HeadingComponent.attribute(:foo)
    end

    it "adds the provided method names to the list of attributes" do
      subject.attributes.foo.should == "bar"
    end
  end

  describe ".option" do
    before do
      HeadingComponent.option(:wrapper, false)
    end

    it "sets the value of the option to the provided value" do
      subject.options.wrapper == false
    end
  end
end
