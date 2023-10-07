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

    it "can be omitted for testing purposes" do
      sm = create(:submission_file)
      assert_not sm.original.attached?
      assert_predicate(sm, :valid?)
    end

    it "enqueues the update job on create" do
      create(:submission_file_with_original, file_name: "1.webp")
      assert_enqueued_jobs 1, only: SubmissionFileUpdateJob
    end

    it "enqueues nothing if the attachment didn't change" do
      sm = create(:submission_file_with_original, file_name: "1.webp")
      assert_no_enqueued_jobs { sm.save }
    end
  end
end
