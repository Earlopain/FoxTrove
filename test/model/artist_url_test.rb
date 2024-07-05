# frozen_string_literal: true

require "test_helper"

class ArtistUrlTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  describe "search" do
    test "it returns results when searching for missing api identifiers" do
      missing_twitter = create(:artist_url, site_type: "twitter", api_identifier: nil)
      create(:artist_url, site_type: "furaffinity", api_identifier: "bar")
      missing_fa = create(:artist_url, site_type: "furaffinity", api_identifier: nil)

      assert_empty(ArtistUrl.search(missing_api_identifier: "1"))
      stub_scraper_enabled(:twitter) do
        assert_equal([missing_twitter], ArtistUrl.search(missing_api_identifier: "1"))
      end
      stub_scraper_enabled(:furaffinity) do
        assert_equal([missing_fa], ArtistUrl.search(missing_api_identifier: "1"))
      end
      stub_scraper_enabled(:twitter, :furaffinity) do
        assert_equal([missing_fa, missing_twitter], ArtistUrl.search(missing_api_identifier: "1"))
      end
    end
  end

  describe "enqueue_scraping" do
    test "with non-scraping url" do
      url = create(:artist_url, site_type: "kofi")
      url.enqueue_scraping
      assert_enqueued_jobs 0
    end

    test "with missing api identifier" do
      url = create(:artist_url, site_type: "twitter", api_identifier: nil)
      assert_raises(ArtistUrl::MissingApiIdentifier) do
        stub_scraper_enabled("twitter") { url.enqueue_scraping }
      end
      assert_enqueued_jobs 0
    end

    test "with scraping url" do
      url = create(:artist_url, site_type: "twitter", api_identifier: "foo")
      stub_scraper_enabled("twitter") { url.enqueue_scraping }
      assert_enqueued_jobs 1, only: ScrapeArtistUrlJob
    end
  end
end
