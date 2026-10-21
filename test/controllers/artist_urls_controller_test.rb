require "test_helper"

class ArtistUrlsControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    create(:artist_url)
    get artist_urls_path
    assert_response :success
  end

  test "show redirects to the artist" do
    artist_url = create(:artist_url)
    get artist_url_path(artist_url)
    assert_redirected_to(artist_path(artist_url.artist, search: { artist_url_id: [artist_url.id] }))
  end

  test "destroy removes the artist url" do
    artist_url = create(:artist_url)
    assert_difference(-> { ArtistUrl.count }, -1) do
      delete artist_url_path(artist_url)
      assert_redirected_to(artist_urls_path)
    end
  end

  test "enqueue" do
    artist_url = create(:artist_url)
    post enqueue_artist_url_path(artist_url)
    assert_response :success
  end

  test "redo for a scraping url enqueues the scraping job and resets last_scraped_at" do
    artist_url = create(:artist_url, last_scraped_at: Time.current, site_type: :furaffinity, api_identifier: "foo")

    stub_scraper_enabled(:furaffinity) do
      put redo_artist_url_path(artist_url)
    end
    assert_response :success
    assert_nil artist_url.reload.last_scraped_at
    assert_enqueued_jobs 1, only: ScrapeArtistUrlJob
  end
end
