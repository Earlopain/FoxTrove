require "test_helper"

class PurgeScraperLogsJobTest < ActiveJob::TestCase
  test "it deletes the correct entries" do
    l1 = create(:scraper_log, created_at: 1.week.ago)
    l2 = create(:scraper_log, created_at: 2.months.ago)

    PurgeScraperLogsJob.new.perform
    assert(ScraperLog.exists?(l1.id))
    assert_not(ScraperLog.exists?(l2.id))
  end
end
