# frozen_string_literal: true

module Config
  module_function

  def default_config
    @default_config ||= begin
      file_config = YAML.load_file(Rails.root.join("config/reverser.yml"), symbolize_names: true)
      scraper_disabled_keys = Sites.scraper_definitions.to_h { |definition| [:"#{definition.site_type}_disabled?", false] }
      file_config.merge(scraper_disabled_keys)
    end
  end

  def custom_config
    @custom_config ||= File.exist?(custom_config_path) ? YAML.load_file(custom_config_path, fallback: {}, symbolize_names: true) : {}
  end

  def custom_config_path
    Rails.root.join("config/reverser_custom_config.yml")
  end

  def merge_custom_config(new_values)
    mapped = new_values.to_h do |k, v|
      if respond_to?(:"#{k}?") || k.end_with?("?")
        ["#{k.to_s.delete_suffix('?')}?", ActiveModel::Type::Boolean.new.cast(v)]
      elsif default_config[k.to_sym].is_a?(Numeric)
        [k, cast_number(v)]
      else
        [k, v]
      end
    end
    custom_config.merge(mapped).transform_keys(&:to_s)
  end

  def write_custom_config(new_values)
    data = Psych.safe_dump(merge_custom_config(new_values))
    File.write(custom_config_path, data)
  end

  def cast_number(value)
    value = value.tr(",", ".").delete_suffix(".0")
    if value.include?(".")
      value.to_f
    else
      value.to_i
    end
  end

  def reset_cache
    @default_config = nil
    @custom_config = nil
  end

  def missing_values
    %i[e6_user e6_apikey].select { |key| send(key).blank? }
  end

  def method_missing(method)
    raise NoMethodError, "Unknown config #{method}" unless respond_to_missing?(method)

    bool_key = method.to_s.delete_suffix("?").to_sym
    if custom_config.key?(bool_key) && method.end_with?("?")
      custom_config[bool_key] == "true"
    elsif custom_config.key?(method)
      custom_config[method]
    else
      default_config[method]
    end
  end

  def respond_to_missing?(method, *)
    default_config.key?(method)
  end
end
