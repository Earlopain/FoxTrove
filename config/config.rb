# frozen_string_literal: true

module Config
  CUSTOM_CONFIG_ENV_KEY = "REVERSER_CUSTOM_CONFIG_PATH"

  def self.default_config
    @default_config ||= YAML.load_file "config/reverser.yml"
  end

  def self.custom_config
    @custom_config ||= File.exist?(ENV[CUSTOM_CONFIG_ENV_KEY] || "") ? YAML.load_file(ENV[CUSTOM_CONFIG_ENV_KEY], fallback: {}) : {}
  end

  def self.force_reload
    @default_config = nil
    @custom_config = nil
  end

  def self.method_missing(method)
    raise StandardError, "Unknown config #{method}" unless respond_to_missing?(method)

    custom_config[method.to_s] || default_config[method.to_s]
  end

  def self.respond_to_missing?(method, *)
    custom_config.keys.concat(default_config.keys).include? method.to_s
  end
end
