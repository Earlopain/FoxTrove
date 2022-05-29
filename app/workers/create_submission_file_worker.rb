class CreateSubmissionFileWorker
  include Sidekiq::Worker

  sidekiq_options queue: :submission_download, lock: :until_executed, lock_ttl: 1.hour,
                  lock_args_method: :lock_args, on_conflict: :log

  def self.lock_args(args)
    [args[0], args[1]["identifier"]]
  end

  def perform(artist_submission_id, file, site_enum)
    submission_file = SubmissionFile.find_by artist_submission_id: artist_submission_id, file_identifier: file["identifier"]
    return if submission_file

    definition = Sites.from_enum(site_enum)
    # Deviantarts download links expire, they need to be fetched when you actually use them
    url = if file["url"].present?
            file["url"]
          else
            # FIXME: This is kind of stupid
            artist_url = ArtistSubmission.find(artist_submission_id).artist_url
            scraper = definition.new_scraper artist_url
            scraper.get_download_link file["url_data"]
          end
    bin_file = Tempfile.new(binmode: true)
    response = Sites.download_file bin_file, url, definition

    raise StandardError, "Failed to download #{url}: #{response.code}" if response.code != 200

    # Deviantart doesn't have to return only images.
    # No way to find this out through the api response as far as I'm aware.
    # https://www.deviantart.com/fr95/art/779625010/
    mime_type = Marcel::MimeType.for bin_file
    return if mime_type.in? Scraper::Submission::MIME_IGNORE

    submission_file = SubmissionFile.new(
      artist_submission_id: artist_submission_id,
      direct_url: url,
      created_at_on_site: file["created_at"],
      file_identifier: file["identifier"]
    )

    blob = ActiveStorage::Blob.create_and_upload!(io: bin_file, filename: File.basename(url))
    begin
      blob.analyze
      raise StandardError, "Failed to analyze" if blob.content_type == "application/octet-stream"

      submission_file.original.attach(blob)
      submission_file.attributes = {
        width: blob.metadata[:width],
        height: blob.metadata[:height],
        content_type: blob.content_type,
        size: blob.byte_size,
      }
      submission_file.save
    rescue StandardError => e
      blob.purge
      raise e
    end
  end
end
