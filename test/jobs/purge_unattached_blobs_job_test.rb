require "test_helper"

class PurgeUnattachedBlobsJobTest < ActiveJob::TestCase
  test "it deletes old unattached blobs" do
    sm_blob = create(:submission_file_with_original, file_name: "1.webp").original.blob
    sm_blob.update(created_at: 1.week.ago)
    other_blob = SubmissionFile.blob_for_io(Tempfile.new(binmode: true), "file1")
    SubmissionFile.blob_for_io(Tempfile.new(binmode: true), "file2").update(created_at: 1.week.ago)

    assert_equal(3, ActiveStorage::Blob.count)
    PurgeUnattachedBlobsJob.new.perform
    assert_equal([sm_blob, other_blob], ActiveStorage::Blob.all)
  end
end
