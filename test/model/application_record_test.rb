# frozen_string_literal: true

require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "when searching for an empty array it returns no results" do
    create(:submission_file, file_error: nil)
    create(:submission_file, file_error: "")
    create(:submission_file, file_error: "abc")
    assert_equal(0, SubmissionFile.attribute_matches([], :file_error).count)
  end

  test "when searching for an empty string it returns correct results" do
    create(:submission_file, file_error: nil)
    result = create(:submission_file, file_error: "")
    create(:submission_file, file_error: "abc")
    assert_equal(result.id, SubmissionFile.attribute_matches("", :file_error).sole.id)
  end

  test "when searching for nil it returns all results" do
    r1 = create(:submission_file, file_error: nil)
    r2 = create(:submission_file, file_error: "")
    r3 = create(:submission_file, file_error: "abc")
    assert_equal([r1.id, r2.id, r3.id], SubmissionFile.attribute_matches(nil, :file_error).pluck(:id))
  end

  test "when searching for nil values" do
    r1 = create(:submission_file, file_error: nil)
    r2 = create(:submission_file, file_error: "abc")
    assert_equal(r1.id, SubmissionFile.attribute_nil_check(false, :file_error).sole.id)
    assert_equal(r2.id, SubmissionFile.attribute_nil_check(true, :file_error).sole.id)
  end

  test "when searching for multiple values" do
    r1 = create(:artist, name: "foo")
    r2 = create(:artist, name: "bar")
    r3 = create(:artist, name: "faz")
    assert_equal([r1.id, r2.id], Artist.attribute_matches("foo,bar", :name).pluck(:id))
    assert_equal([r2.id, r3.id], Artist.attribute_matches("*a*", :name).pluck(:id))
    assert_equal([r1.id, r2.id], Artist.attribute_matches("foo,*r", :name).pluck(:id))
  end

  test "when searching by join attribute it returns the match only once" do
    result = create(:artist)
    create_list(:artist_url, 2, artist: result, site_type: "twitter")
    assert_equal(result.id, Artist.join_attribute_matches("twitter", artist_urls: :site_type).sole.id)
  end
end
