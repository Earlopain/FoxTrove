class PurgeScraperLogsJob < ApplicationJob
  def perform
    ScraperLog.where(created_at: ..1.month.ago).delete_all
  end
end
