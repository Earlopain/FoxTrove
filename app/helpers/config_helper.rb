module ConfigHelper
  def strip_config_prefix(definition, key)
    key.to_s.delete_prefix("#{definition.site_type}_")
  end

  def definition_status(definition)
    if definition.manually_disabled?
      "❌ Manually disabled"
    elsif definition.missing_config_keys.any?
      missing = definition.missing_config_keys.map { |key| strip_config_prefix(definition, key) }
      "❌ Missing config #{'key'.pluralize(missing.count)}: #{missing.join(', ')}"
    elsif !definition.scraper?
      "❌ Removed"
    else
      "✅ Enabled"
    end
  end
end
