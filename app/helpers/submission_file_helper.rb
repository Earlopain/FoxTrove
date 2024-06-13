# frozen_string_literal: true

module SubmissionFileHelper
  def display_artist_name?(submission_file)
    s1 = submission_file.artist_url.url_identifier.downcase
    s2 = submission_file.artist.name.downcase
    s1.gsub(/\W+/, "") != s2.gsub(/\W+/, "")
  end

  def submission_file_tag(submission_file)
    dimensions = { width: submission_file.width, height: submission_file.height }
    sample = image_tag(submission_file.url_for(:sample), loading: "lazy", class: "submission-file", **dimensions, data: { corrupt: submission_file.corrupt? })
    sample + original_file_tag(submission_file)
  end

  def original_file_tag(submission_file)
    url = submission_file.url_for(:original)
    dimensions = { width: submission_file.width, height: submission_file.height }
    if submission_file.original.content_type.in? ["video/mp4", "video/webm", "video/quicktime"]
      video_tag(url, controls: false, class: "submission-file-full hidden", **dimensions)
    else
      image_tag(url, loading: "lazy", class: "submission-file-full hidden", **dimensions)
    end
  end
end
