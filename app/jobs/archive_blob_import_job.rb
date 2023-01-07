# frozen_string_literal: true

class ArchiveBlobImportJob < ApplicationJob
  queue_as :submission_download
  retry_on StandardError, attempts: 5
  good_job_control_concurrency_with(total_limit: 1, key: -> { arguments.third })

  def perform(blob_id, artist_submission_id, zip_file_path)
    blob = ActiveStorage::Blob.find_by id: blob_id
    artist_submission = ArtistSubmission.find_by id: artist_submission_id
    return unless blob && artist_submission
    return if artist_submission.submission_files.exists?(file_identifier: zip_file_path)

    SubmissionFile.from_attachable(
      attachable: blob,
      artist_submission_id: artist_submission.id,
      url: "file:///#{zip_file_path}",
      created_at: artist_submission.created_at_on_site,
      file_identifier: zip_file_path,
    )
  end
end
