#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

E6IqdbData.where(post_json: nil).pluck(:post_id).uniq.each_slice(100) do |post_ids|
  E6ApiClient.get_posts_by_id(post_ids).each do |api_post|
    E6IqdbData.where(post_id: api_post["id"]).update!(post_json: api_post)
  end
end
