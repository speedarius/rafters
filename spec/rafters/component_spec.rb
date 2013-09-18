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
      subject.options.wrapper.should == true
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
      subject.settings.title.should == "Heading Component"
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
end
