class Rafters::Component
  attr_accessor :identifier, :local_options, :local_settings
  attr_writer :controller

  def initialize(identifier, options = {})
    settings = options.delete(:settings) || {}

    @identifier = identifier
    @local_options = options
    @local_settings = settings
  end

  def options
    @options ||= objectify_with_merge_chain(klass_options, local_options, param_options)
  end

  def settings
    @settings ||= objectify_with_merge_chain(klass_settings, local_settings, param_settings).tap do |_settings|
      klass_setting_options.each do |setting, options|
        raise SettingRequired, "#{setting} is required" if options[:required] && _settings[setting].nil?
      end
    end
  end

  def attributes
    @attributes ||= objectify.tap do |_attributes|
      klass_attributes.each do |attribute|
        _attributes[attribute] = send(attribute)
      end
    end
  end

  def source
    @source ||= options.source_name ? options.source_name.constantize.new(self) : nil
  end

  def locals
    attributes.merge(settings: settings, component: self)
  end

  def as_json(*args)
    { identifier: identifier, options: options.as_json(*args), settings: settings.as_json(*args) }.as_json
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

  def params
    controller(:params)
  end

  class << self
    attr_accessor :_attributes, :_settings, :_setting_options, :_options

    def inherited(base)
      base.option(:wrapper, true)
      base.option(:view_name, base.name.underscore)
      base.option(:source_name, nil)
    end

    def setting(name, options = {})
      (self._settings ||= {})[name] = options.delete(:default)
      (self._setting_options ||= {})[name] = options
    end

    def attribute(name)
      (self._attributes ||= []) << name
    end

    def option(name, value)
      (self._options ||= {})[name] = value
    end

    def settings(settings = {})
      settings.each { |name, options| setting(name, options) }
    end

    def attributes(*names)
      names.each { |name| attribute(name) }
    end

    def options(options = {})
      options.each { |name, value| option(name, value) }
    end
  end

  private

  def klass_attributes
    self.class._attributes || []
  end

  def klass_options
    self.class._options || {}
  end

  def klass_settings
    self.class._settings || {}
  end

  def klass_setting_options
    self.class._setting_options || {}
  end

  def param_options
    params[identifier] || {}
  end

  def param_settings
    param_options[:settings] || {}
  end

  def merge_chain(*links)
    {}.tap do |chain|
      links.each do |link|
        chain.merge!(link)
      end
    end
  end

  def objectify(hash = {})
    Hashie::Mash.new(hash)
  end

  def objectify_with_merge_chain(*links)
    objectify.tap do |object|
      merge_chain(*links).each do |option, value|
        object[option] = coerce_value(value)
      end
    end
  end

  def coerce_value(value)
    if value == "true" || value == "1"
      return true
    elsif value == "false" || value == "0" || value == "nil"
      return false
    elsif value.is_a?(Proc)
      value.call(self)
    else 
      return value
    end
  end

  class SettingRequired < StandardError; end
end
