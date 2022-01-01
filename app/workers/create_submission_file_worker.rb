class CreateSubmissionFileWorker
  include Sidekiq::Worker

  sidekiq_options queue: :submission_download, lock: :until_executed, lock_ttl: 1.hour,
                  lock_args_method: :lock_args, on_conflict: :log

  def self.lock_args(args)
    [args[0], args[1]]
  end

  def perform(artist_submission_id, file_identifier, created_at, url, site_enum)
    submission_file = SubmissionFile.find_by artist_submission_id: artist_submission_id, file_identifier: file_identifier
    return if submission_file

    definition = Sites.from_enum(site_enum)
    begin
      uri = Addressable::URI.parse url
    rescue Addressable::URI::InvalidURIError
      logger.info "Invalid url for artist_submission_id #{artist_submission_id}: #{url}"
      return
    end
    bin_file = Tempfile.new(binmode: true)
    # TODO: Error handling
    Sites.download_file bin_file, uri, definition
    submission_file = SubmissionFile.new(
      artist_submission_id: artist_submission_id,
      direct_url: url,
      created_at_on_site: created_at,
      file_identifier: file_identifier
    )
    submission_file.original.attach(io: bin_file, filename: File.basename(uri.path))
    submission_file.save
  end
end
