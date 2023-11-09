# frozen_string_literal: true

require "test_helper"

class GoodJobTest < ActiveSupport::TestCase
  test "current migrations are applied" do
    assert_predicate GoodJob, :migrated?
  end

  test "concurrency keys are scoped by job class and queue" do
    artist_url = create(:artist_url)
    job = ScrapeArtistUrlJob.perform_later(artist_url)
    assert_equal("ScrapeArtistUrlJob-scraping-#{artist_url.id}", job.good_job_concurrency_key)
  end
end
