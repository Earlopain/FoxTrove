require "test_helper"

class E6IqdbQueryJobTest < ActiveJob::TestCase
  # Import a file, which gets assigned a reverser iqdb hash.
  # Import another file, which also gets a reverser iqdb hash.
  # The second file is an exact md5 match to the e6 iqdb result.
  # The reverser iqdb hash of the first and second file are identical.
  # Therefore the first file is also an exact match.
  it "updates the exact match flag for an already existing visual match when the files are visually identical" do
    exact_match = create(:submission_file_with_original, file_name: "1.webp", with_sample: true, iqdb_hash: 0x0102)
    existing_e6_visual_match = create(:e6_post, post_id: 1, submission_file: create(:submission_file, iqdb_hash: 0x0102), is_exact_match: false)

    stub_e6_post(build(:e6_post_response, post_id: 1, md5: "28327bc4d327f130e609cd4467db71df")) do
      stub_e6_iqdb(build(:e6_iqdb_response, post_ids: [1])) do
        E6IqdbQueryJob.new.perform(exact_match)
        assert exact_match.e6_posts.first.reload.is_exact_match
        assert existing_e6_visual_match.reload.is_exact_match
      end
    end
  end
end
