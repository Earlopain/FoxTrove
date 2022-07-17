# frozen_string_literal: true

class E6IqdbQueryWorker
  include Sidekiq::Worker

  sidekiq_options queue: :e6_iqdb, lock: :until_executed, lock_ttl: 1.hour, on_conflict: :log, lock_args_method: :lock_args

  def self.lock_args(args)
    [args[0]]
  end

  def perform(submission_file_id, remove_similar)
    return unless E6ApiClient.iqdb_enabled?

    submission_file = SubmissionFile.find_by id: submission_file_id
    return unless submission_file

    submission_file.update_e6_iqdb_data(remove_similar: remove_similar)
  end
end
