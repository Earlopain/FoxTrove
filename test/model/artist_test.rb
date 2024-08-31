require "test_helper"

class ArtistTest < ActiveSupport::TestCase
  describe "oldest_last_scraped_at" do
    test "it returns the oldest timestamp" do
      artist = create(:artist)
      create(:artist_url, site_type: :twitter, artist: artist, last_scraped_at: Time.current)
      match = create(:artist_url, site_type: :twitter, artist: artist, last_scraped_at: 10.hours.ago)
      stub_scraper_enabled(:twitter) do
        assert_equal(match.last_scraped_at, artist.oldest_last_scraped_at)
      end
    end

    test "when not every url is scraped" do
      artist = create(:artist)
      create(:artist_url, site_type: :twitter, artist: artist, last_scraped_at: Time.current)
      create(:artist_url, site_type: :twitter, artist: artist, last_scraped_at: nil)
      stub_scraper_enabled(:twitter) do
        assert_nil(artist.oldest_last_scraped_at)
      end
    end
  end
end
