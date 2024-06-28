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

  test "index renders" do
    create(:artist)
    create(:artist_url)
    create(:submission_file)

    get artists_path
    assert_response :success
  end

  describe "create" do
    test "create with no urls" do
      post artists_path(artist: { name: "foo", url_string: "" })
      assert_redirected_to(url_for(Artist.first))
    end

    test "create with scraper enabled" do
      stub_request(:get, "https://piczel.tv/api/users/foo?friendly=1").to_return(body: { id: 123 }.to_json)
      stub_scraper_enabled(:artstation) do
        post artists_path(artist: { name: "foo", url_string: "piczel.tv/gallery/foo" })
      end

      assert_response :found
      assert_equal("123", ArtistUrl.last.api_identifier)
      assert_enqueued_jobs 1
      assert_enqueued_with(job: ScrapeArtistUrlJob, args: [ArtistUrl.last])
    end

    test "create with scraper enabled when the second url fails enqueues no jobs" do
      stub_request(:get, "https://piczel.tv/api/users/foo?friendly=1").to_return(body: { id: 123 }.to_json)
      stub_scraper_enabled(:artstation) do
        post artists_path(artist: { name: "foo", url_string: "piczel.tv/gallery/foo\nbar" })
      end

      assert_response :unprocessable_content
      assert_enqueued_jobs 0
    end
  end
end
