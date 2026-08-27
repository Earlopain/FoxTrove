require "test_helper"

class ArtistSubmissionTest < ActiveSupport::TestCase
  it "prevents saving with identical identifier for the same url" do
    artist_url = create(:artist_url)
    create(:artist_submission, artist_url: artist_url, identifier_on_site: "foo")

    assert_nothing_raised do
      # different casing
      create(:artist_submission, artist_url: artist_url, identifier_on_site: "FOO")
      # different artist url
      create(:artist_submission, identifier_on_site: "foo")
    end

    assert_raises(ActiveRecord::RecordInvalid, match: /Identifier on site has already been taken/) do
      create(:artist_submission, artist_url: artist_url, identifier_on_site: "foo")
    end
  end
end
