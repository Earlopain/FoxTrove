# frozen_string_literal: true

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
end
