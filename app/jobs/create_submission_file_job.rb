# frozen_string_literal: true

class CreateSubmissionFileJob < ApplicationJob
  queue_as :submission_download
  good_job_control_concurrency_with(total_limit: 1, key: -> { "#{arguments.first.id}-#{arguments.second[:identifier]}" })

  def perform(artist_submission, file)
    submission_file = SubmissionFile.find_by(artist_submission: artist_submission, file_identifier: file[:identifier])
    return if submission_file

    # Deviantarts download links expire, they need to be fetched when you actually use them
    url = file[:url].presence || artist_submission.artist_url.scraper.get_download_link(file[:url_data])
    bin_file = Tempfile.new(binmode: true)
    response = Sites.download_file bin_file, url

    raise StandardError, "Failed to download #{url}: #{response.code}" if response.code != 200

    SubmissionFile.from_attachable(
      attachable: bin_file,
      artist_submission: artist_submission,
      url: url,
      created_at: file[:created_at],
      file_identifier: file[:identifier],
    )
  end
end
