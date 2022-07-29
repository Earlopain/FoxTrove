# frozen_string_literal: true

class SubmissionFileUpdateWorker
  include Sidekiq::Worker

  sidekiq_options queue: :variant_generation, lock: :until_executed, lock_ttl: 1.hour,
                  lock_args_method: :lock_args, on_conflict: :log

  def self.lock_args(args)
    [args[0]]
  end

  def perform(submission_file_id)
    submission_file = SubmissionFile.find_by id: submission_file_id
    return unless submission_file

    submission_file.generate_variants
    submission_file.save
    return unless submission_file.can_iqdb?

    IqdbProxy.update_submission submission_file
    E6IqdbQueryWorker.perform_async submission_file.id, false
  end
end
