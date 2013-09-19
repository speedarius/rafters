class Rafters::Component
  attr_writer :controller, :local_options, :local_settings
  attr_reader :identifier

  def initialize(identifier, options = {})
    settings = options.delete(:settings) || {}

    @identifier = identifier
    @local_options = options
    @local_settings = settings
  end

  def options
    @options ||= evaluate_options_merge_chain(@local_options).tap do |hash|
      replace_with_result!(hash, :cast_value_from_string)
    end
  end

  def settings
    @settings ||= evaluate_settings_merge_chain(@local_settings).tap do |hash|
      replace_with_result!(hash, :cast_value_from_string)
    end
  end

  def attributes
    @attributes ||= Hashie::Mash.new.tap do |_attributes|
      default_attributes.each do |name|
        _attributes[name] = send(name)
      end
    end
  end

  def source
    @source ||= (options.source_name ? options.source_name.constantize.new(self) : nil)
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
    attr_accessor :_attributes, :_settings, :_options

    def inherited(base)
      base.option :wrapper, true
      base.option :view_name, base.name.underscore
      base.option :source_name, nil
    end

    def setting(name, options = {})
      (self._settings ||= {})[name] = options
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
      (self._options ||= {})[name] = value
    end

    def options(options = {})
      options.each do |name, value|
        option(name, value)
      end
    end
  end

  private

  def default_attributes
    self.class._attributes || {}
  end

  def default_options
    self.class._options || {}
  end

  def default_settings
    {}.tap do |_default_settings|
      (self.class._settings || {}).each do |name, options|
        _default_settings[name] = options[:default]
      end
    end
  end

  def param_options
    HashWithIndifferentAccess.new(params[identifier] || {})
  end

  def param_settings
    HashWithIndifferentAccess.new(param_options[:settings] || {})
  end

  def evaluate_settings_merge_chain(local_settings)
    apply_merge_chain!(default_settings, local_settings, param_settings)
  end

  def evaluate_options_merge_chain(local_options)
    apply_merge_chain!(default_options, local_options, param_options)
  end

  def apply_merge_chain!(*links)
    Hashie::Mash.new.tap do |chain|
      links.each { |link| chain.merge!(link) }
    end
  end

  def replace_with_result!(hash, method)
    hash.each do |key, value|
      hash[key] = send(method, value)
    end
  end

  def cast_value_from_string(value)
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
end
