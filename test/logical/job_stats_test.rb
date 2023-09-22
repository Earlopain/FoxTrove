# frozen_string_literal: true

require "test_helper"

class JobStatsTest < ActiveSupport::TestCase
  it "returns enqueued jobs" do
    url1 = create(:artist_url)
    submission1, submission2 = create_list(:artist_submission, 2, artist_url: url1)
    file1, file2 = create_list(:submission_file, 2, artist_submission: submission1)
    file3 = create(:submission_file, artist_submission: submission2)

    url2 = create(:artist_url)
    submission3 = create(:artist_submission, artist_url: url2)
    file4, file5 = create_list(:submission_file, 2, artist_submission: submission3)

    # Should not match for active_urls
    _url3 = create(:artist_url)

    [url1, url2].each { |url| ScrapeArtistUrlJob.perform_later(url) }
    [submission1, submission2, submission3].each { |submission| CreateSubmissionFileJob.perform_later(submission, {}) }
    [file1, file2, file3, file4, file5].each { |file| E6IqdbQueryJob.perform_later(file) }

    stats = JobStats.new

    assert_equal({ url1.id => 1, url2.id => 1 }, stats.scraping_queued)
    assert_equal({ url1.id => 2, url2.id => 1 }, stats.submission_download_queued)
    assert_equal({ url1.id => 3, url2.id => 2 }, stats.e6_iqdb_queued)
    assert_equal([url1.id, url2.id].sort, stats.active_urls.sort)
  end

  it "returns the correct values for currently running scraping jobs" do
    url1, url2, url3 = create_list(:artist_url, 3)
    ScrapeArtistUrlJob.perform_later(url1)
    ScrapeArtistUrlJob.perform_later(url2)
    ScrapeArtistUrlJob.perform_later(url3)

    # Fool GoodJob into thinking some jobs are actually running
    GoodJob::Job.stubs(:running).returns(GoodJob::Job.where(finished_at: nil))
    GoodJob::Job.order(:created_at).second.update(finished_at: Time.current)

    assert_equal([url1.id, url3.id].sort, JobStats.new.scraping_now.sort)
  end
end
