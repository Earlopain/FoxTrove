# frozen_string_literal: true

require "test_helper"

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  describe "enqueue_everything" do
    it "enqueues the correct amount of jobs" do
      artist1 = create(:artist)
      create(:artist_url, artist: artist1, site_type: :furaffinity, api_identifier: "1")
      create(:artist_url, artist: artist1, site_type: :twitter, api_identifier: "2")
      artist2 = create(:artist)
      create(:artist_url, artist: artist2, site_type: :twitter, api_identifier: "3")
      create(:artist_url, artist: artist2, site_type: :carrd)

      stub_scraper_enabled(:furaffinity, :twitter) do
        post enqueue_everything_artists_path
      end
      assert_response :success
      assert_enqueued_jobs 3, only: ScrapeArtistUrlJob
    end
  end
end
