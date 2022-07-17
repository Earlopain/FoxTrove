# frozen_string_literal: true

namespace :iqdb do
  desc "Readd all files to iqdb"
  task readd: :environment do
    total = SubmissionFile.count
    SubmissionFile.find_each.with_index do |submission_file, index|
      puts "#{index}/#{total}" if index % 100 == 0
      IqdbProxy.update_submission submission_file if submission_file.can_iqdb?
    end
  end
end
