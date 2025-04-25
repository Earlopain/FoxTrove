require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  def assert_equal_any_order(expected, actual)
    assert_equal(expected.sort_by(&:id), actual.sort_by(&:id))
  end

  test "when searching for an empty array it returns no results" do
    create(:submission_file, file_error: nil)
    create(:submission_file, file_error: "")
    create(:submission_file, file_error: "abc")
    assert_empty(SubmissionFile.attribute_matches([], :file_error))
  end

  test "when searching for an empty string it returns correct results" do
    create(:submission_file, file_error: nil)
    result = create(:submission_file, file_error: "")
    create(:submission_file, file_error: "abc")
    assert_equal(result, SubmissionFile.attribute_matches("", :file_error).sole)
  end

  test "when searching by integer field" do
    sm1, _, sm3 = create_list(:submission_file, 3)
    assert_equal_any_order([sm1, sm3], SubmissionFile.attribute_matches("#{sm1.id},#{sm3.id}", :id))
  end

  test "when searching by jsonb field" do
    e1 = create(:log_event, payload: { foo: "bar" })
    e2 = create(:log_event, payload: { baz: "bat" })
    e3 = create(:log_event, payload: { xyz: "123" })
    assert_equal_any_order([e1, e2], LogEvent.attribute_matches("*b*", :payload))
    assert_equal_any_order([e3], LogEvent.attribute_matches("*xyz*", :payload))
  end

  test "when searching for nil it returns all results" do
    r1 = create(:submission_file, file_error: nil)
    r2 = create(:submission_file, file_error: "")
    r3 = create(:submission_file, file_error: "abc")
    assert_equal_any_order([r1, r2, r3], SubmissionFile.attribute_matches(nil, :file_error))
  end

  test "when searching for nil values" do
    r1 = create(:submission_file, file_error: nil)
    r2 = create(:submission_file, file_error: "abc")
    assert_equal(r1, SubmissionFile.attribute_nil_check(false, :file_error).sole)
    assert_equal(r2, SubmissionFile.attribute_nil_check(true, :file_error).sole)
  end

  test "when searching for multiple values" do
    r1 = create(:artist, name: "foo")
    r2 = create(:artist, name: "bar")
    r3 = create(:artist, name: "faz")
    assert_equal_any_order([r1, r2], Artist.attribute_matches("foo,bar", :name))
    assert_equal_any_order([r2, r3], Artist.attribute_matches("*a*", :name))
    assert_equal_any_order([r1, r2], Artist.attribute_matches("foo,*r", :name))
  end

  test "when searching by join attribute it returns the match only once" do
    result = create(:artist)
    create_list(:artist_url, 2, artist: result, site_type: "twitter")
    assert_equal(result, Artist.join_attribute_matches("twitter", artist_urls: :site_type).sole)
  end
end
