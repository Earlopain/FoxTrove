#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

def redownload(submission_file)
  bin_file = Tempfile.new(binmode: true)
  response = Sites.download_file(bin_file, submission_file.direct_url)
  if response.code == 200
    begin
      submission_file.attach_original!(bin_file)
      true
    rescue Vips::Error
      false
    end
  else
    false
  end
end

# [123].each do |submission_file|
SubmissionFile.find_each do |submission_file|
  submission_file = SubmissionFile.find(submission_file) if submission_file.is_a?(Integer)
  next unless submission_file.can_iqdb?

  begin
    Vips::Image.new_from_file(submission_file.original.service.path_for(submission_file.original.key), fail: true).stats
  rescue Vips::Error
    success = redownload(submission_file)
    puts "#{submission_file.id} failed" unless success
  end
end
