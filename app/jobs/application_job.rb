# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on StandardError, wait: :polynomially_longer, attempts: 25 do |_job, exception|
    log_exception(exception)
  end
  discard_on ActiveJob::DeserializationError

  around_perform do |_job, block|
    logger.log_at(:debug) do
      block.call
    end
  rescue StandardError => e
    log_exception(e)
    raise
  end

  private

  def log_exception(exception)
    logger.error(exception.message)
    logger.error(exception.backtrace.join("\n"))
  end
end
