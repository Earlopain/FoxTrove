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
      assert_nothing_raised { SubmissionFile.find(sm.id).update!(file_identifier: "bar") }
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
    end

    it "enqueues the analyze job for the generated sample" do
      create(:submission_file_with_original, file_name: "1.webp", with_sample: true)
      assert_enqueued_jobs 1, only: ActiveStorage::AnalyzeJob
    end

    it "enqueues nothing if the attachment didn't change" do
      sm = create(:submission_file_with_original, file_name: "1.webp")
      assert_no_enqueued_jobs { sm.save }
    end

    it "handles corrupt files" do
      sm = create(:submission_file_with_original, file_name: "corrupt.jpg")
      assert_predicate sm, :corrupt?
      assert_match(/VipsJpeg: Premature end/i, sm.file_error)
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

  it "respects the limit setting during pagination" do
    create_list(:submission_file, 3)

    _, sm = SubmissionFile.pagy({})
    assert_equal(3, sm.count)

    stub_config(files_per_page: 2) do
      _, sm = SubmissionFile.pagy({})
    end
    assert_equal(2, sm.count)
  end

  describe "search" do
    it "returns results for larger by filesize absolute" do
      sm1 = create(:submission_file, size: 200.kilobytes)
      create(:e6_post, submission_file: sm1, post_size: 50.kilobytes)
      sm2 = create(:submission_file, size: 60.kilobytes)
      create(:e6_post, submission_file: sm2, post_size: 50.kilobytes)

      assert_equal([sm2, sm1], SubmissionFile.search(upload_status: "larger_only_filesize_kb", larger_only_filesize_treshold: 5))
      assert_equal([sm1], SubmissionFile.search(upload_status: "larger_only_filesize_kb", larger_only_filesize_treshold: 50))
    end

    it "returns results for larger by filesize relative" do
      sm1 = create(:submission_file, size: 1.megabyte)
      create(:e6_post, submission_file: sm1, post_size: 0.5.kilobytes)
      sm2 = create(:submission_file, size: 1.megabyte)
      create(:e6_post, submission_file: sm2, post_size: 0.85.megabytes)

      assert_equal([sm2, sm1], SubmissionFile.search(upload_status: "larger_only_filesize_percentage", larger_only_filesize_treshold: 10))
      assert_equal([sm1], SubmissionFile.search(upload_status: "larger_only_filesize_percentage", larger_only_filesize_treshold: 40))
    end

    it "returns results for larger by dimensions" do
      sm1, sm2 = create_list(:submission_file, 2, width: 100, height: 100)
      create(:e6_post, submission_file: sm1, post_width: 50, post_height: 50)
      create(:e6_post, submission_file: sm2, post_width: 150, post_height: 150)

      assert_equal([sm1], SubmissionFile.search(upload_status: "larger_only_dimensions"))
    end

    it "returns results for already uploaded" do
      sm1, sm2 = create_list(:submission_file, 3)
      create(:e6_post, submission_file: sm1)
      create(:e6_post, submission_file: sm2)

      assert_equal([sm2, sm1], SubmissionFile.search(upload_status: "already_uploaded"))
    end

    it "returns results for exact matches" do
      sm1, sm2, _sm3 = create_list(:submission_file, 3)
      create(:e6_post, submission_file: sm1, is_exact_match: true)
      create(:e6_post, submission_file: sm1, is_exact_match: false)
      create(:e6_post, submission_file: sm2, is_exact_match: false)

      assert_equal([sm1], SubmissionFile.search(upload_status: "exact_match_exists"))
    end

    it "returns results for not uploaded" do
      sm1, sm2, sm3 = create_list(:submission_file, 3)
      create_list(:e6_post, 2, submission_file: sm1)
      create(:e6_post, submission_file: sm2)

      assert_equal([sm3], SubmissionFile.search(upload_status: "not_uploaded"))
    end

    it "returns results for zero sources" do
      sm1, sm2 = create_list(:submission_file, 2)
      create(:e6_post, submission_file: sm1, post_json: { sources: [] })
      create(:e6_post, submission_file: sm2, post_json: { sources: ["whatever"] })

      assert_equal([sm1], SubmissionFile.search(zero_sources: "1"))
    end

    it "returns results for zero artists" do
      sm1, sm2 = create_list(:submission_file, 2)
      create(:e6_post, submission_file: sm1, post_json: { tags: { artist: [] } })
      create(:e6_post, submission_file: sm2, post_json: { tags: { artist: ["foo"] } })

      assert_equal([sm1], SubmissionFile.search(zero_artists: "1"))
    end

    it "returns results for zero sources mixed with zero artists" do
      sm1, sm2, sm3 = create_list(:submission_file, 3)
      create(:e6_post, submission_file: sm1, post_json: { tags: { artist: ["foo"] }, sources: [] })
      create(:e6_post, submission_file: sm2, post_json: { tags: { artist: [] }, sources: [] })
      create(:e6_post, submission_file: sm3, post_json: { tags: { artist: [] }, sources: ["foo"] })

      assert_equal([sm2], SubmissionFile.search(zero_sources: "1", zero_artists: "1"))
    end

    it "respects the score cutoff value" do
      sm1, sm2, sm3 = create_list(:submission_file, 3)
      create(:e6_post, submission_file: sm1, similarity_score: 90)
      create(:e6_post, submission_file: sm1, similarity_score: 75)
      create(:e6_post, submission_file: sm2, similarity_score: 75)
      create(:e6_post, submission_file: sm3, similarity_score: 50)

      stub_config(similarity_cutoff: 40) do
        assert_equal([sm3, sm2, sm1], SubmissionFile.search(upload_status: "already_uploaded"))
      end

      stub_config(similarity_cutoff: 60) do
        assert_equal([sm2, sm1], SubmissionFile.search(upload_status: "already_uploaded"))
      end

      stub_config(similarity_cutoff: 80) do
        assert_equal([sm1], SubmissionFile.search(upload_status: "already_uploaded"))
      end
    end
  end
end
