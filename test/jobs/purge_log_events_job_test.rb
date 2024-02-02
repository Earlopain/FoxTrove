# frozen_string_literal: true

require "test_helper"

class PurgeLogEventsJobTest < ActiveJob::TestCase
  test "it deletes the correct entries" do
    l1 = create(:log_event, created_at: 1.week.ago)
    l2 = create(:log_event, created_at: 2.months.ago)

    PurgeLogEventsJob.new.perform
    assert(LogEvent.exists?(l1.id))
    assert_not(LogEvent.exists?(l2.id))
  end
end
