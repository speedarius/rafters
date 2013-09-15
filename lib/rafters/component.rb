class Rafters::Component
  attr_writer :controller
  attr_reader :identifier, :view_name, :source_name, :local_settings

  def initialize(options = {})
    @identifier = options.delete(:as) || self.class.name.dasherize
    @view_name = options.delete(:view_name) || self.class.name.underscore
    @source_name = options.delete(:source_name)
    @local_settings = options[:settings] || {}
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

  def source
    @source ||= source_name ? source_name.constantize.new(self) : nil
  end

  def settings
    @settings ||= Hashie::Mash.new.tap do |_settings|
      _settings.merge!(default_settings)
      _settings.merge!(local_settings)
      _settings.merge!(parameter_settings)
    end
  end

  def attributes
    @attributes ||= Hashie::Mash.new.tap do |_attributes|
      (self.class._attributes || {}).each do |name|
        _attributes[name] = send(name)
      end
    end
  end

  def locals
    attributes.merge(settings: settings, component: self)
  end

  def as_json(options = {})
    { identifier: identifier, view_name: view_name, source_name: source_name, settings: settings.as_json }
  end

  class << self
    attr_accessor :_settings, :_default_settings, :_attributes

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
  end

  private

  def default_settings
    self.class._default_settings || {}
  end

  def parameter_settings
    parameters = controller(:params)
    parameters[identifier] || {}
  end
end
