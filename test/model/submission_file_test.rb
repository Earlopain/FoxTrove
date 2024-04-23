# frozen_string_literal: true

require "test_helper"

class SubmissionFileTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  describe "#original" do
    it "must be attached on create" do
      e = assert_raises(ActiveRecord::RecordInvalid) { create(:submission_file, skip_original_validation: false) }
      assert_match(/Original file not attached/, e.message)
    end

    it "prevents removal once attached" do
      sm = create(:submission_file_with_original, file_name: "1.webp")
      sm.original.purge
      e = assert_raises(ActiveRecord::RecordInvalid) { sm.save! }
      assert_match(/Original file not attached/, e.message)
    end

    it "allows updating unrelated attributes" do
      sm = create(:submission_file_with_original, file_name: "1.webp")
      sm.update!(file_identifier: "foo")
      SubmissionFile.find(sm.id).update!(file_identifier: "bar")
    end

    it "allows replacing the original" do
      sm = create(:submission_file_with_original, file_name: "1.webp")
      sm.update!(original: file_fixture("1.jpg"))
      assert_equal("1.jpg", sm.original.blob.filename.to_s)
    end

    it "can be omitted for testing purposes" do
      sm = create(:submission_file)
      assert_not sm.original.attached?
      assert_predicate(sm, :valid?)
    end

    it "enqueues the update job on create" do
      create(:submission_file_with_original, file_name: "1.webp")
      assert_enqueued_jobs 1, only: SubmissionFileUpdateJob
      assert_enqueued_jobs 1
    end

    it "enqueues nothing if the attachment didn't change" do
      sm = create(:submission_file_with_original, file_name: "1.webp")
      assert_no_enqueued_jobs { sm.save }
    end

    it "handles corrupt files" do
      sm = create(:submission_file_with_original, file_name: "corrupt.jpg")
      assert_predicate sm, :corrupt?
      assert_equal "VipsJpeg: Premature end of input file", sm.file_error
    end

    it "purges the blob on errors in from_attachable" do
      artist_submission = create(:artist_submission)
      file = Tempfile.new(binmode: true)
      file << "\xE4\xC9\xF3\xDE\xB1\x9F\xBE\xD1\xC1\xF6" # Just some random data

      assert_no_difference(-> { ActiveStorage::Blob.count }, -> { SubmissionFile.count }) do
        assert_raises(match: "Failed to analyze") do
          SubmissionFile.from_attachable(
            attachable: file,
            artist_submission: artist_submission,
            url: "file:///123.jpg",
            created_at: artist_submission.created_at_on_site,
            file_identifier: "123",
          )
        end
      end
    end

    it "ignores files with undesired content types" do
      artist_submission = create(:artist_submission)
      file = Tempfile.new(binmode: true)
      file << "FLV" # video/x-flv

      assert_no_difference(-> { ActiveStorage::Blob.count }, -> { SubmissionFile.count }) do
        SubmissionFile.from_attachable(
          attachable: file,
          artist_submission: artist_submission,
          url: "file:///123.jpg",
          created_at: artist_submission.created_at_on_site,
          file_identifier: "123",
        )
      end
    end
  end
end
