# frozen_string_literal: true

require "test_helper"

class ArtistUrlTest < ActiveSupport::TestCase
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
end
