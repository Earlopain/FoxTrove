# frozen_string_literal: true

require "test_helper"

module Scraper
  class LiveTest < ActiveSupport::TestCase
    if ENV["LIVE_TESTS"]
      puts "Live tests require selenium to be running and may ask you to solve captchas"

      setup do
        WebMock.disable!
        Config.unstub(:custom_config)
        # Supress api identifier fetching during callbacks
        ArtistUrl.any_instance.stubs(:scraper_enabled?).returns(false)
      end

      def test_scraper(scraper_class, identifier, id, skip_files: false)
        artist_url = create(:artist_url, url_identifier: identifier, site_type: scraper_class.site_type)
        missing_keys = artist_url.site.missing_config_keys
        skip "Skipping #{scraper_class.site_type}: missing #{missing_keys}" if missing_keys.any?

        assert_equal(id, artist_url.scraper.fetch_api_identifier)
        artist_url.api_identifier = id
        assert_not_empty(artist_url.scraper.fetch_next_batch) unless skip_files
      end

      def url(identifier)
        build(:artist_url, url_identifier: identifier)
      end

      test "artconomy" do
        test_scraper(Scraper::Artconomy, "Nikkibunn", 117)
      end

      test "artfight" do
        test_scraper(Scraper::Artfight, "Coco_Line", "428743")
      end

      test "artstation" do
        test_scraper(Scraper::Artstation, "ilyar", 75_315)
      end

      test "baraag" do
        test_scraper(Scraper::Baraag, "keki", "447907")
      end

      test "commishes" do
        test_scraper(Scraper::Commishes, "TotesFleisch8", 839)
      end

      test "deviantart" do
        test_scraper(Scraper::Deviantart, "steven-huang", "E636E615-F7CA-6BB7-71DC-39655C6E24AF")
      end

      test "furaffinity" do
        test_scraper(Scraper::Furaffinity, "kenket", "kenket")
      end

      test "furrynetwork" do
        test_scraper(Scraper::Furrynetwork, "ruaidri", 25_140)
      end

      test "inkbunny" do
        test_scraper(Scraper::Inkbunny, "s1m", "485588")
      end

      test "itaku" do
        test_scraper(Scraper::Itaku, "saucy", 17_141)
      end

      test "newgrounds" do
        test_scraper(Scraper::Newgrounds, "the-minuscule-task", "7139598")
      end

      test "omorashi" do
        test_scraper(Scraper::Omorashi, "166217-wildagram", "166217")
      end

      test "pawoo" do
        test_scraper(Scraper::Pawoo, "sifyro", "1528165")
      end

      test "piczel" do
        test_scraper(Scraper::Piczel, "Waga", 11_175)
      end

      test "pixiv" do
        test_scraper(Scraper::Pixiv, "23343984", "23343984")
      end

      test "reddit" do
        test_scraper(Scraper::Reddit, "ygabyt", "2rtbdwfz")
      end

      test "sofurry" do
        test_scraper(Scraper::Sofurry, "zummeng", "373836")
      end

      test "tumblr" do
        test_scraper(Scraper::Tumblr, "yuumei-art", "t:DlrWdEaIry0XVtS7NBwpHQ", skip_files: true)
      end

      test "twitter" do
        test_scraper(Scraper::Twitter, "Jacato", "925849246309519360")
      end

      test "weasyl" do
        test_scraper(Scraper::Weasyl, "qualzar", "3721")
      end
    end
  end
end
