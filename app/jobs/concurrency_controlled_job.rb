# frozen_string_literal: true

class ConcurrencyControlledJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  # Automatically scope keys to the job/queue.
  def _good_job_concurrency_key
    "#{self.class.name}-#{queue_name}-#{super}"
  end
end
