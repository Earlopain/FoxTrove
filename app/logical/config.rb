# frozen_string_literal: true

module Config
  module_function

  def default_config
    @default_config ||= YAML.load_file(Rails.root.join("config/reverser.yml"))
  end

  def custom_config
    @custom_config ||= File.exist?(custom_config_path) ? YAML.load_file(custom_config_path, fallback: {}) : {}
  end

  def env_config
    @env_config ||= begin
      app_env = env.select { |k| k.downcase.start_with?("reverser_") }
      app_env.to_h { |k, v| [k.downcase.delete_prefix("reverser_"), Psych.safe_load(v)] }
    end
  end

  def custom_config_path
    env_config["custom_config_path"] || Rails.root.join(default_config["custom_config_path"])
  end

  def force_reload
    @default_config = nil
    @custom_config = nil
    @env_config = nil
  end

  def missing_values
    %i[e6_user e6_apikey].select { |key| send(key).blank? }
  end

  def method_missing(method)
    raise NoMethodError, "Unknown config #{method}" unless respond_to_missing?(method)

    if env_config.key? method.to_s.chomp("?")
      env_config[method.to_s.chomp("?")]
    elsif custom_config.key? method.to_s
      custom_config[method.to_s]
    else
      default_config[method.to_s]
    end
  end

  def respond_to_missing?(method, *)
    default_config.key? method.to_s
  end

  # This is only here to stub in tests
  def env
    ENV
  end
end
