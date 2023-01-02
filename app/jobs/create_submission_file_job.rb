# frozen_string_literal: true

class CreateSubmissionFileJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency
  queue_as :submission_download
  good_job_control_concurrency_with(total_limit: 1, key: -> { "#{arguments.first}-#{arguments.second['identifier']}" })

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

    SubmissionFile.from_file(
      file: bin_file,
      artist_submission_id: artist_submission_id,
      url: url,
      created_at: file["created_at"],
      file_identifier: file["identifier"],
    )
  end
end
