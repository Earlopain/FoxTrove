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

    jobs = []
    jobs = jobs.concat [url1, url2].map { |url| ScrapeArtistUrlJob.perform_later(url) }
    jobs = jobs.concat [submission1, submission2, submission3].map { |submission| CreateSubmissionFileJob.perform_later(submission, {}) }
    jobs = jobs.concat [file1, file2, file3, file4, file5].map { |file| E6IqdbQueryJob.perform_later(file) }
    
    ids = [url1, url2, submission1, submission2, submission3, file1, file2, file3, file4, file5].map(&:id)
    ids.zip(jobs).each do |id, job|
      puts "#{id}:#{job.class} => #{job.good_job_concurrency_key if job}"
    end

    assert_equal(10, GoodJob::Job.count)
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
