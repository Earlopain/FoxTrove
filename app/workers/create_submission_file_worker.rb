# frozen_string_literal: true

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

    # Deviantarts download links expire, they need to be fetched when you actually use them
    url = if file["url"].present?
            file["url"]
          else
            # FIXME: This is kind of stupid
            artist_url = ArtistSubmission.find(artist_submission_id).artist_url
            scraper = Sites.from_enum(site_enum).new_scraper artist_url
            scraper.get_download_link file["url_data"]
          end
    bin_file = Tempfile.new(binmode: true)
    response = Sites.download_file bin_file, url

    raise StandardError, "Failed to download #{url}: #{response.code}" if response.code != 200

    SubmissionFile.from_bin_file(bin_file, artist_submission_id: artist_submission_id,
                                           url: url,
                                           created_at: file["created_at"],
                                           file_identifier: file["identifier"])
  end
end
