class E6IqdbQueryWorker
  include Sidekiq::Worker

  sidekiq_options queue: :e6_iqdb, lock: :until_executed, lock_ttl: 1.hour, on_conflict: :log

  def perform(submission_file_id)
    submission_file = SubmissionFile.find_by id: submission_file_id
    return unless submission_file

    submission_file.update_e6_iqdb_data
  end
end
