# frozen_string_literal: true

module Config
  module_function

  def default_config
    @default_config ||= YAML.load_file "config/reverser.yml"
  end

  def custom_config
    @custom_config ||= begin
      File.exist?(Config.custom_config_path) ? YAML.load_file(Config.custom_config_path, fallback: {}) : {}
    end
  end

  def env_config
    @env_config ||= begin
      app_env = ENV.select { |k| k.downcase.start_with?("reverser_") }
      app_env.to_h { |k, v| [k.downcase.delete_prefix("reverser_"), Psych.safe_load(v, fallback: nil)] }
    end
  end

  def custom_config_path
    env_config["custom_config_path"] || default_config["custom_config_path"]
  end

  def force_reload
    @default_config = nil
    @custom_config = nil
    @env_config = nil
  end

  def method_missing(method)
    raise StandardError, "Unknown config #{method}" unless respond_to_missing?(method)

    env_config[method.to_s.chomp("?")] || custom_config[method.to_s] || default_config[method.to_s]
  end

  def respond_to_missing?(method, *)
    default_config.keys.include? method.to_s
  end
end
