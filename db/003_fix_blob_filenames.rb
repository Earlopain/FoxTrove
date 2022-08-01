#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

ActiveStorage::Blob.where("filename like ?", "%?%").find_each do |blob|
  blob.update!(filename: File.basename(URI.parse(blob.filename.to_s).path))
end
