module Config
  DEFAULT_PATH = Rails.root.join("config/foxtrove.yml")
  CUSTOM_PATH = Rails.root.join("config/foxtrove_custom_config.yml")

  module_function

  def default_config
    @default_config ||= begin
      file_config = YAML.load_file(DEFAULT_PATH, symbolize_names: true)
      scraper_disabled_keys = Sites.scraper_definitions.to_h { |definition| [:"#{definition.site_type}_disabled?", false] }
      file_config.merge(scraper_disabled_keys)
    end
  end

  def custom_config
    @custom_config ||= CUSTOM_PATH.exist? ? YAML.load_file(CUSTOM_PATH, fallback: {}, symbolize_names: true) : {}
  end

  def merge_custom_config(new_values)
    mapped = new_values.to_h do |k, v|
      k = :"#{k}?" if respond_to?(:"#{k}?")
      case default_config[k.to_sym]
      when TrueClass, FalseClass
        [k, ActiveModel::Type::Boolean.new.cast(v)]
      when Numeric
        [k, cast_number(v)]
      else
        [k, v]
      end
    end
    custom_config.merge(mapped).transform_keys(&:to_s)
  end

  def write_custom_config(new_values)
    data = Psych.safe_dump(merge_custom_config(new_values))
    File.write(CUSTOM_PATH, data)
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
    if custom_config.key?(method)
      custom_config[method]
    elsif default_config.key?(method)
      default_config[method]
    else
      super
    end
  end

  def respond_to_missing?(method, *)
    default_config.key?(method)
  end
end
