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
    @template_name ||= begin
      _template_name = (self.class._template_name || self.class.name.underscore)
      
      if _template_name.is_a?(Proc)
        _template_name = _template_name.call(self)
      end

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
    return {} if self.class._settings.nil?

    @_settings ||= Hashie::Mash.new.tap do |_settings|
      self.class._settings.each do |name, options|
        _settings[name] = (@settings[name] || options[:default] || nil)
        raise SettingRequired if options[:required] && _settings[name].nil?
      end
    end
  end

  def current(variable_or_method_name)
    if @controller.instance_variable_defined?("@#{variable_or_method_name}")
      @controller.instance_variable_get("@#{variable_or_method_name}")
    elsif @controller.respond_to?(variable_or_method_name, true)
      @controller.send(variable_or_method_name)
    else
      raise CurrentVariableOrMethodNameMissing
    end
  end

  module ClassMethods
    attr_accessor :_attributes, :_settings, :_template_name

    def attribute(name)
      self._attributes ||= []
      self._attributes << name
    end

    def setting(name, options = {})
      self._settings ||= {}
      self._settings[name.to_sym] = options
    end

    def template_name(name)
      self._template_name = name.to_s
    end
  end

  class CurrentVariableOrMethodNameMissing < StandardError; end
  class SettingRequired < StandardError; end
end
