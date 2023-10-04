# frozen_string_literal: true

module Config
  module_function

  def default_config
    @default_config ||= YAML.load_file(Rails.root.join("config/reverser.yml"), symbolize_names: true)
  end

  def custom_config
    @custom_config ||= File.exist?(custom_config_path) ? YAML.load_file(custom_config_path, fallback: {}, symbolize_names: true) : {}
  end

  def custom_config_path
    Rails.root.join("config/reverser_custom_config.yml")
  end

  def force_reload
    @default_config = nil
    @custom_config = nil
  end

  def missing_values
    %i[e6_user e6_apikey].select { |key| send(key).blank? }
  end

  def method_missing(method)
    raise NoMethodError, "Unknown config #{method}" unless respond_to_missing?(method)

    if custom_config.key?(method)
      custom_config[method]
    else
      default_config[method]
    end
  end

  def respond_to_missing?(method, *)
    default_config.key?(method)
  end
end
