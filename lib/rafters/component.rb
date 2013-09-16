class Rafters::Component
  attr_writer :controller
  attr_reader :identifier

  def initialize(identifier, options = {})
    settings = options.delete(:settings) || {}

    @identifier = identifier
    @local_options = options
    @local_settings = settings
  end

  def options
    @options ||= evaluate_options_merge_chain(@local_options).tap do |_options|
      _options.each do |name, value|
        _options[name] = value.is_a?(Proc) ? value.call(self) : value
      end
    end
  end

  def settings
    @settings ||= evaluate_settings_merge_chain(@local_settings).tap do |_settings|
      _settings.each do |name, value|
        _settings[name] = value.is_a?(Proc) ? value.call(self) : value
      end
    end
  end

  def attributes
    @attributes ||= Hashie::Mash.new.tap do |_attributes|
      (self.class._attributes || {}).each do |name|
        _attributes[name] = send(name)
      end
    end
  end

  def view_name
    @view_name ||= (options[:view_name] || self.class.name.underscore)
  end

  def source_name
    @source_name ||= options[:source_name]
  end

  def source
    @source ||= (source_name ? source_name.constantize.new(self) : nil)
  end

  def locals
    attributes.merge(settings: settings, component: self)
  end

  def as_json(options = {})
    { identifier: identifier, view_name: view_name, source_name: source_name, settings: settings.as_json }
  end

  def controller(variable_or_method_name)
    if @controller.instance_variable_defined?("@#{variable_or_method_name}")
      @controller.instance_variable_get("@#{variable_or_method_name}")
    elsif @controller.respond_to?(variable_or_method_name, true)
      @controller.send(variable_or_method_name)
    else
      nil
    end
  end

  class << self
    attr_accessor :_attributes, :_settings, :_default_settings, :_default_options

    def extended(base)
      base.options wrapper: true
    end

    def setting(name, options = {})
      (self._settings ||= []) << name
      (self._default_settings ||= {})[name] = options[:default] || nil
    end

    def settings(settings = {})
      settings.each do |name, options|
        setting(name, options)
      end
    end

    def attribute(name)
      (self._attributes ||= []) << name
    end

    def attributes(*names)
      names.each do |name|
        attribute(name)
      end
    end

    def option(name, value)
      (self._default_options ||= {})[name] = value
    end

    def options(options = {})
      options.each do |name, value|
        option(name, value)
      end
    end
  end

  private

  def default_options
    self.class._default_options || {}
  end

  def default_settings
    self.class._default_settings || {}
  end

  def parameter_options
    parameters = controller(:params)
    parameters[identifier] || {}
  end

  def parameter_settings
    parameter_options[:settings] || {}
  end

  def evaluate_settings_merge_chain(local_settings)
    Hashie::Mash.new.tap do |_settings|
      [default_settings, local_settings, parameter_settings].each do |overrides|
        _settings.merge!(overrides)
      end
    end
  end

  def evaluate_options_merge_chain(local_options)
    Hashie::Mash.new.tap do |_options|
      [default_options, local_options, parameter_options].each do |overrides|
        _options.merge!(overrides)
      end
    end
  end
end
