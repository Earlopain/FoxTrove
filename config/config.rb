module Config
  CUSTOM_CONFIG_ENV_KEY = "REVERSER_CUSTOM_CONFIG_PATH".freeze

  def self.default_config
    @default_config ||= YAML.load_file "config.yml"
  end

  def self.custom_config
    @custom_config ||= ENV[CUSTOM_CONFIG_ENV_KEY] ? YAML.load_file(ENV[CUSTOM_CONFIG_ENV_KEY]) : {}
  end

  def self.force_reload
    @default_config = nil
    @custom_config = nil
  end

  def self.method_missing(method)
    if custom_config.keys.include? method.to_s
      custom_config[method.to_s]
    elsif default_config.keys.include? method.to_s
      default_config[method.to_s]
    else
      raise StandardError, "Unknown config #{method}"
    end
  end
end
