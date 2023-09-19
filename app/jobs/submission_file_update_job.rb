# frozen_string_literal: true

class SubmissionFileUpdateJob < ApplicationJob
  queue_as :variant_generation

  def perform(submission_file)
    submission_file.generate_variants
    submission_file.save
    return unless submission_file.can_iqdb?

    IqdbProxy.update_submission submission_file
    E6IqdbQueryJob.set(priority: E6IqdbQueryJob::PRIORITIES[:automatic_action]).perform_later(submission_file)
  end
end
