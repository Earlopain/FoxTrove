#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

SubmissionFile.where(content_type: "video/mp4").find_each(&:generate_variants)
