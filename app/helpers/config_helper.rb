# frozen_string_literal: true

module ConfigHelper
  def strip_config_prefix(definition, key)
    key.to_s.delete_prefix("#{definition.site_type}_")
  end
end
