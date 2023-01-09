#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

to_update = E6Post.where("post_json->'file' is null")
puts "Updating #{to_update.count} entries"
to_update.find_in_batches(batch_size: 99) do |batch|
  post_ids = batch.map(&:post_id)
  json = E6ApiClient.get_posts(post_ids).index_by { |p| p["id"] }
  batch.each do |entry|
    entry.post_json = json[entry.post_id]
    entry.save
  end
end
