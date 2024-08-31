class PurgeLogEventsJob < ApplicationJob
  def perform
    LogEvent.where(created_at: ..1.month.ago).delete_all
  end
end
