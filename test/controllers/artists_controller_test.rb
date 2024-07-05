# frozen_string_literal: true

require "test_helper"

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  test "enqueue_all_urls" do
    artist = create(:artist)
    create(:artist_url, artist: artist, site_type: :furaffinity, api_identifier: "1")
    create(:artist_url, artist: artist, site_type: :twitter, api_identifier: "2")
    create(:artist_url, artist: artist, site_type: :carrd)

    stub_scraper_enabled(:furaffinity, :twitter) do
      post enqueue_all_urls_artist_path(artist)
    end
    assert_response :success
    assert_enqueued_jobs 2, only: ScrapeArtistUrlJob
  end

  test "enqueue_everything" do
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

  test "index renders" do
    create(:artist)
    create(:artist_url)
    create(:submission_file)

    get artists_path
    assert_response :success
  end

  test "show renders" do
    sm = create(:submission_file_with_original, file_name: "1.jpg")
    get artist_path(sm.artist)
    assert_response :success
  end

  test "new renders" do
    get new_artist_path
    assert_response :success
  end

  describe "create" do
    test "create with no urls" do
      post artists_path(artist: { name: "foo", url_string: "" })
      assert_redirected_to(url_for(Artist.first))
    end

    test "create with an invalid artist name" do
      post artists_path(artist: { name: "!invalid", url_string: "foo" })
      assert_response :unprocessable_content
      assert_equal("Name '!invalid' can only contain alphanumerics and _.-+()", css_select("#form-error").inner_text)
    end

    test "create with invalid url" do
      assert_no_difference(-> { Artist.count }, -> { ArtistUrl.count }) do
        post artists_path(artist: { name: "foo", url_string: "foo" })
      end
      assert_response :unprocessable_content
    end

    test "create with unsupported url" do
      post artists_path(artist: { name: "foo", url_string: "https://example.com" })
      assert_response :unprocessable_content
      assert_equal("Url https://example.com is not a supported url", css_select("#form-error").inner_text)
    end

    test "create with invalid artist identifier" do
      post artists_path(artist: { name: "foo", url_string: "https://furaffinity.net/user/!invalid" })
      assert_response :unprocessable_content
      assert_equal("Identifier !invalid is not valid for FurAffinity", css_select("#form-error").inner_text)
    end

    test "create rolls back if second url is invalid" do
      assert_no_difference(-> { Artist.count }, -> { ArtistUrl.count }) do
        post artists_path(artist: { name: "foo", url_string: "https://ko-fi.com/foo\nbar" })
      end
      assert_response :unprocessable_content
    end

    test "create rolls back if second url is duplicate" do
      create(:artist_url, site_type: "furaffinity", url_identifier: "foo")
      assert_no_difference(-> { Artist.count }, -> { ArtistUrl.count }) do
        post artists_path(artist: { name: "foo", url_string: "https://ko-fi.com/foo\nhttps://furaffinity.net/user/foo" })
      end
      assert_response :unprocessable_content
      assert_equal("https://furaffinity.net/user/foo is not valid: Url identifier has already been taken", css_select("#form-error").inner_text)
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

    test "create with failed api lookup" do
      stub_request(:get, "https://piczel.tv/api/users/foo?friendly=1").to_return(status: 404)
      stub_scraper_enabled(:artstation) do
        post artists_path(artist: { name: "foo", url_string: "piczel.tv/gallery/foo" })
      end

      assert_response :unprocessable_content
      assert_equal("piczel.tv/gallery/foo is not valid: foo failed api lookup (Not Found)", css_select("#form-error").inner_text)
    end

    test "create with api lookup returns nil" do
      stub_request(:get, "https://piczel.tv/api/users/foo?friendly=1").to_return(body: {}.to_json)
      stub_scraper_enabled(:artstation) do
        post artists_path(artist: { name: "foo", url_string: "piczel.tv/gallery/foo" })
      end

      assert_response :unprocessable_content
      assert_equal("piczel.tv/gallery/foo is not valid: foo failed api lookup", css_select("#form-error").inner_text)
    end

    test "create with errored api lookup" do
      stub_request(:get, "https://piczel.tv/api/users/foo?friendly=1").to_return(status: 500)
      stub_scraper_enabled(:artstation) do
        post artists_path(artist: { name: "foo", url_string: "piczel.tv/gallery/foo" })
      end

      assert_response :unprocessable_content
      assert_equal("piczel.tv/gallery/foo is not valid: foo failed api lookup (Internal Server Error)", css_select("#form-error").inner_text)
    end
  end

  test "update adds new urls" do
    artist = create(:artist)
    create(:artist_url, site_type: "kofi")

    assert_difference(-> { ArtistUrl.count }, 1) do
      put artist_path(artist, artist: { url_string: "https://foo.carrd.co" })
      assert_redirected_to(artist_path(artist))
    end
  end

  test "edit renders" do
    artist = create(:artist)
    get edit_artist_path(artist)
    assert_response :success
  end

  test "destroy renders" do
    artist = create(:artist)
    assert_difference(-> { Artist.count }, -1) do
      delete artist_path(artist)
      assert_redirected_to(artists_path)
    end
  end
end
