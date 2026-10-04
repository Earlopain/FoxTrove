require "test_helper"

class E6IqdbQueryJobTest < ActiveJob::TestCase
  # Import a file, which gets assigned an iqdb hash.
  # Import another file, which also gets an iqdb hash.
  # The second file is an exact md5 match to the e6 iqdb result.
  # The iqdb hash of the first and second file are identical.
  # Therefore the first file is also an exact match.
  test "the exact match flag for an already existing visual match is updated when the files are visually identical" do
    exact_match = create(:submission_file_with_original, file_name: "1.webp", with_sample: true, iqdb_hash: 0x0102)
    existing_e6_visual_match = create(:e6_post, post_id: 1, submission_file: create(:submission_file, iqdb_hash: 0x0102), is_exact_match: false)

    stub_e6_iqdb(build(:e6_iqdb_response, post_ids: [1])) do
      E6IqdbQueryJob.new.perform(exact_match)
      assert exact_match.e6_posts.first.reload.is_exact_match
      assert existing_e6_visual_match.reload.is_exact_match
    end
  end

  test "the last queried timestamp is updated" do
    submission_file = create(:submission_file_with_original, file_name: "1.webp", with_sample: true)
    assert_nil submission_file.last_iqdb_checked_at

    stub_e6_iqdb(build(:e6_iqdb_response, post_ids: [])) do
      E6IqdbQueryJob.new.perform(submission_file)
    end

    updated_timestamp = submission_file.last_iqdb_checked_at
    assert updated_timestamp

    stub_e6_iqdb(build(:e6_iqdb_response, post_ids: [])) do
      E6IqdbQueryJob.new.perform(submission_file)
    end

    assert_operator updated_timestamp, :<, submission_file.last_iqdb_checked_at
  end
end
