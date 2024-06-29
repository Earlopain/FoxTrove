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
    delete artist_url_path(artist_url)

    assert_redirected_to(artist_urls_path)
    assert_not(ArtistUrl.exists?(artist_url.id))
  end
end
