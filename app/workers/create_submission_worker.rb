class CreateSubmissionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :submission_download, lock: :until_executed, lock_ttl: 1.hour,
                  lock_args_method: :lock_args, on_conflict: :log

  def self.lock_args(args)
    [args[0]]
  end

  def perform(submission_id, urls, site_enum)
    submission = ArtistSubmission.find_by id: submission_id
    return unless submission

    definition = Sites::Definitions.from_enum(site_enum)
    urls.each do |url|
      begin
        uri = Addressable::URI.parse url
      rescue Addressable::URI::InvalidURIError
        logger.info "Invalid url for submission_id #{submission_id}: #{url}"
        next
      end
      file = Tempfile.new(binmode: true)
      # TODO: Error handling
      Sites.download_file file, uri, definition
      submission_file = SubmissionFile.new(artist_submission: submission, direct_url: url)
      submission_file.original.attach(io: file, filename: File.basename(uri.path))
      success = submission_file.save
      CreateVariantsWorker.perform_async submission_file.id if success
    end
  end
end
