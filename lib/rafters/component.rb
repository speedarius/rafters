module Rafters::Component
  extend ActiveSupport::Concern

  attr_writer :controller

  included do
    attribute :settings
  end

  def initialize(settings = {})
    @settings = settings
  end

  def template_name
    @_template_name ||= begin
      _template_name = (self.class._template_name || self.class.name.underscore)
      _template_name = _template_name.call(self) if _template_name.is_a?(Proc)
      _template_name
    end
  end

  def attributes
    return {} if self.class._attributes.nil?

    @_attributes ||= Hashie::Mash.new.tap do |_attributes|
      self.class._attributes.each do |name|
        _attributes[name] = send(name)
      end
    end
  end

  def settings
    @_settings ||= Hashie::Mash.new(@settings.reverse_merge(self.class._defaults || {}))
  end

  def controller(variable_or_method_name)
    if @controller.instance_variable_defined?("@#{variable_or_method_name}")
      @controller.instance_variable_get("@#{variable_or_method_name}")
    elsif @controller.respond_to?(variable_or_method_name, true)
      @controller.send(variable_or_method_name)
    else
      raise ControllerMethodOrVariableMissing, "#{variable_or_method_name.to_s} not found in #{@controller.class.name}"
    end
  end

  private

  module ClassMethods
    attr_accessor :_attributes, :_defaults, :_template_name

    def attribute(name)
      self._attributes ||= []
      self._attributes << name
    end

    def attributes(*names)
      names.each { |name| attribute(name) }
    end

    def default(name, value)
      self._defaults ||= {}
      self._defaults[name] = value
    end

    def defaults(settings = {})
      settings.each { |name, value| default(name, value) }
    end

    def template_name(name)
      self._template_name = name.to_s
    end
  end

  class ControllerMethodOrVariableMissing < StandardError; end
  class SettingRequired < StandardError; end
  class InvalidSetting < StandardError; end
end
