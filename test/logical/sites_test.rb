# frozen_string_literal: true

require "test_helper"

class SitesTest < ActiveSupport::TestCase
  it "returns the correct definition for enum lookups" do
    twitter = Sites.from_enum("twitter")
    twitch = Sites.from_enum("twitch")
    assert_predicate(twitter, :scraper?)
    assert_equal("Twitter", twitter.display_name)
    assert_not_predicate(twitch, :scraper?)
    assert_equal("Twitch", twitch.display_name)
  end

  describe "fix_url" do
    def expect_correct_escaping(input, output)
      assert_equal(output, Sites.fix_url(input).to_s)
      assert_equal(output, Sites.fix_url(output).to_s)
    end

    it "correctly escapes cyrilic characters" do
      input = "https://d.furaffinity.net/art/peyzazhik/1629082282/1629082282.peyzazhik_заливать-гитару.jpg"
      output = "https://d.furaffinity.net/art/peyzazhik/1629082282/1629082282.peyzazhik_%D0%B7%D0%B0%D0%BB%D0%B8%D0%B2%D0%B0%D1%82%D1%8C-%D0%B3%D0%B8%D1%82%D0%B0%D1%80%D1%83.jpg"
      expect_correct_escaping(input, output)
    end

    it "correctly escapes square brackets" do
      input = "https://d.furaffinity.net/art/nawka/1642391380/1642391380.nawka__sd__kwaza_and_hector_[final].jpg"
      output = "https://d.furaffinity.net/art/nawka/1642391380/1642391380.nawka__sd__kwaza_and_hector_%5Bfinal%5D.jpg"
      expect_correct_escaping(input, output)
    end

    it "correctly escapes ＠" do
      input = "https://d.furaffinity.net/art/fr95/1635001690/1635001679.fr95_co＠f-r9512.png"
      output = "https://d.furaffinity.net/art/fr95/1635001690/1635001679.fr95_co%EF%BC%A0f-r9512.png"
      expect_correct_escaping(input, output)
    end

    it "assumes https when no scheme is present" do
      input  = "//art.ngfiles.com/comments/2000/iu_2391_7119353.jpg"
      output = "https://art.ngfiles.com/comments/2000/iu_2391_7119353.jpg"
      expect_correct_escaping(input, output)
    end
  end

  describe "from_gallery_url" do
    def assert_extracted(url, site_type, username, valid: true)
      result = Sites.from_gallery_url(url)
      assert(result, "expected #{url} to match")
      assert_equal(site_type, result[:site].site_type, "expected #{url} to be #{site_type}")
      assert_equal(username, result[:identifier], "expected #{url} to be #{username}")
      assert_equal(valid, result[:valid], "expected #{url} to be #{valid ? 'valid' : 'invalid'}")
    end

    it "correctly extracts information from twitter" do
      assert_extracted("https://twitter.com/username", "twitter", "username")
      assert_extracted("https://twitter.com/@username", "twitter", "username")
      assert_extracted("https://twitter.com/!invalid!", "twitter", "!invalid!", valid: false)
    end

    it "correctly extracts information from furaffinity" do
      assert_extracted("https://furaffinity.net/user/abc", "furaffinity", "abc")
      assert_extracted("https://sfw.furaffinity.net/user/abc", "furaffinity", "abc")
    end

    it "correctly extracts information from reddit" do
      assert_extracted("https://reddit.com/u/abc", "reddit", "abc")
      assert_extracted("https://old.reddit.com/u/abc", "reddit", "abc")
      assert_extracted("https://new.reddit.com/u/abc", "reddit", "abc")
    end

    it "correctly extracts information from pixiv" do
      assert_extracted("pixiv.net/member.php?id=123", "pixiv", "123")
      assert_extracted("https://pixiv.net/en/users/123", "pixiv", "123")
      assert_extracted("https://pixiv.net/jp/users/123", "pixiv", "123")
    end

    it "returns nil when no definitions match" do
      result = Sites.from_gallery_url("https://example.com")
      assert_nil(result)
    end
  end

  describe "download_file" do
    it "properly handles redirects" do
      redirect_url = "https://example.com/redirected"
      initial_request = stub_request_once(:get, "https://example.com", body: "Your are being redirected", status: 302, headers: { Location: redirect_url })
      redirect_request = stub_request_once(:get, redirect_url, body: "Actual content")

      Sites.download_file("https://example.com") do |file|
        assert_requested(initial_request)
        assert_requested(redirect_request)
        assert_equal("Actual content", file.read)
      end
    end
  end

  test "all scrapers are mentioned in the readme" do
    lines = Rails.root.join("README.md").read
      .split("<!--- sites:start -->\n")[1]
      .split("<!--- sites:stop -->")[0]
      .lines
    images, sites = lines
      .filter_map { |l| l.scan(/\* <img src="(.*)" width="16px" height="16px"> ([^(]+?)(?:\n| \()/).first }
      .flatten.partition.with_index { |_, index| index.even? }

    assert_equal(images.count, lines.count, "Unparsable line in readme scraper section")

    display_names = Sites.scraper_definitions.map(&:display_name)
    diff = (sites - display_names) | (display_names - sites)

    assert_equal(Sites.scraper_definitions.count, sites.count, "Readme sites are out of sync: #{diff}")
    assert_equal(sites.map(&:downcase).sort, sites.map(&:downcase), "Readme sites are not sorted")

    images.zip(sites).each do |image, site|
      scraper = Sites.scraper_definitions.find { |definition| definition.display_name == site }
      assert(scraper, "Scraper definition for display name #{site} not found")
      assert_path_exists(image)
      assert_equal(scraper.site_type, Pathname.new(image).basename.to_s.split(".")[0].split("-")[1], "Wrong image for #{site}")
    end
  end
end
