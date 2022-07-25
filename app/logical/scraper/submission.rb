# frozen_string_literal: true

module Scraper
  class Submission
    attr_accessor :identifier, :created_at, :title, :description, :files

    MIME_IGNORE = %w[
      application/x-shockwave-flash
      video/x-flv
      application/vnd.adobe.flash.movie
      image/vnd.adobe.photoshop
      application/pdf
      application/zip
    ].freeze

    def initialize
      @files = []
    end

    def add_file(file)
      return if MIME_IGNORE.include? file[:mime_type]

      files.push(file)
    end

    def save(artist_url)
      artist_submission = ArtistSubmission.find_by(
        artist_url: artist_url,
        identifier_on_site: identifier,
      )

      # No submission was created yet
      artist_submission ||= ArtistSubmission.create!(
        artist_url: artist_url,
        identifier_on_site: identifier,
        title_on_site: fix_encoding(title),
        description_on_site: fix_encoding(description),
        created_at_on_site: created_at,
      )

      files.each do |file|
        # Make arguments sidekiq safe
        file[:created_at] = file[:created_at].to_s
        file = file.stringify_keys
        CreateSubmissionFileWorker.perform_async artist_submission.id, file, artist_url.site.enum_value
      end
    end

    private

    def fix_encoding(input)
      # https://www.furaffinity.net/view/33525724 contains invalid UTF-8
      input.encode(input.encoding, input.encoding, invalid: :replace)
    end
  end
end
