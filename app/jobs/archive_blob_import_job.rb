class ArchiveBlobImportJob < ConcurrencyControlledJob
  queue_as :submission_download
  retry_on StandardError, attempts: 5
  good_job_control_concurrency_with(total_limit: 1, key: -> { arguments.third })

  def perform(blob, artist_submission, zip_file_path)
    return if artist_submission.submission_files.exists?(file_identifier: zip_file_path)

    SubmissionFile.from_attachable(
      attachable: blob,
      artist_submission: artist_submission,
      url: "file:///#{zip_file_path}",
      created_at: artist_submission.created_at_on_site,
      file_identifier: zip_file_path,
    )
  end
end
