#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

E6IqdbData.find_each do |data|
  deleted_json = data.post_json["is_deleted"].nil? ? data.post_json.dig("flags", "deleted") : data.post_json["is_deleted"]
  data.update(post_is_deleted: deleted_json) if deleted_json != data.post_is_deleted
end
