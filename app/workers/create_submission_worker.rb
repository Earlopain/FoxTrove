class CreateSubmissionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :submission_download, lock: :until_executed, lock_ttl: 1.hour,
                  lock_args_method: :lock_args, on_conflict: :log

  def self.lock_args(args)
    [args[0]]
  end

  def perform(submission_id, files, site_enum)
    submission = ArtistSubmission.find_by id: submission_id
    return unless submission

    definition = Sites.from_enum(site_enum)
    files.each do |file|
      url = file["url"]
      created_at = file["created_at"]
      begin
        uri = Addressable::URI.parse url
      rescue Addressable::URI::InvalidURIError
        logger.info "Invalid url for submission_id #{submission_id}: #{url}"
        next
      end
      bin_file = Tempfile.new(binmode: true)
      # TODO: Error handling
      Sites.download_file bin_file, uri, definition
      submission_file = SubmissionFile.new(artist_submission: submission, direct_url: url, created_at_on_site: created_at)
      submission_file.original.attach(io: bin_file, filename: File.basename(uri.path))
      success = submission_file.save
      CreateVariantsWorker.perform_async submission_file.id if success
    end
  end
end
