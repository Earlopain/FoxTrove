# frozen_string_literal: true

module Archives
  class Manual < Base
    def import_submission_files(artist_id, source_url)
      raise ArgumentError, "Artist id must be set" if artist_id.blank?
      raise ArgumentError, "Submission URL must be set" if source_url.blank?

      artist_url = ArtistUrl.find_or_create_by!(site_type: "manual", artist_id: artist_id) do |url|
        url.url_identifier = "manual-#{artist_id}"
        url.created_at_on_site = Time.current
        url.about_on_site = ""
      end

      artist_submission = ArtistSubmission.find_or_create_by!(artist_url: artist_url, identifier_on_site: source_url) do |submission|
        submission.title_on_site = ""
        submission.description_on_site = ""
        submission.created_at_on_site = Time.current
      end

      Zip::File.open(@file) do |zip_file|
        zip_file.glob("**/*.*").each do |entry|
          import_file(artist_submission, entry)
        end
      end
    end
  end
end
