# frozen_string_literal: true

RSpec.describe Sites do
  it "returns the correct definition for enum lookups" do
    expect(described_class.from_enum("twitter")).to be_a Sites::Definitions::Twitter
    expect(described_class.from_enum("twitch")).to be_a Sites::Definitions::Twitch
  end

  describe "fix_url" do
    def expect_correct_escaping(input, output)
      expect(described_class.fix_url(input).to_s).to eq(output)
      expect(described_class.fix_url(output).to_s).to eq(output)
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
