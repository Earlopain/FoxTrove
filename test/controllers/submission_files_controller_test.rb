# frozen_string_literal: true

require "test_helper"

class SubmissionFilesControllerTest < ActionDispatch::IntegrationTest
  test "last known good" do
    artist_url = create(:artist_url, last_scraped_at: Time.current)
    sm = create(:submission_file, artist_submission: create(:artist_submission, artist_url: artist_url), created_at_on_site: 7.days.ago)

    put set_last_known_good_submission_file_path(sm)
    assert_response :success
    assert_in_delta artist_url.reload.last_scraped_at, 8.days.ago, 1
  end
end
