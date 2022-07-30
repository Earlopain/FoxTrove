#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

SubmissionFile.where(iqdb_hash: nil).find_each do |s|
  s.iqdb_hash = IqdbProxy.get_submission_hash(s.id)
  s.save
end
