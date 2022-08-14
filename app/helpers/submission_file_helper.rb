# frozen_string_literal: true

module SubmissionFileHelper
  def display_artist_name?(submission_file)
    s1 = submission_file.artist_url.url_identifier.downcase
    s2 = submission_file.artist.name.downcase
    s1.gsub(/\W+/, "") != s2.gsub(/\W+/, "")
  end
end
