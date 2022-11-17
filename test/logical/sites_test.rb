# frozen_string_literal: true

require "test_helper"

class SitesTest < ActiveSupport::TestCase
  it "returns the correct definition for enum lookups" do
    twitter = Sites.from_enum("twitter")
    twitch = Sites.from_enum("twitch")
    assert_instance_of(Sites::ScraperDefinition, twitter)
    assert_equal("Twitter", twitter.display_name)
    assert_instance_of(Sites::SimpleDefinition, twitch)
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
end
