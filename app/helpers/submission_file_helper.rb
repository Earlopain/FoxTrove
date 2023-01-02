# frozen_string_literal: true

module SubmissionFileHelper
  def display_artist_name?(submission_file)
    s1 = submission_file.artist_url.url_identifier.downcase
    s2 = submission_file.artist.name.downcase
    s1.gsub(/\W+/, "") != s2.gsub(/\W+/, "")
  end

  def original_file_tag(submission_file)
    url = url_for(submission_file.original)
    if submission_file.original.content_type == "video/mp4"
      video_tag url, controls: false, class: "submission-file-full hidden"
    else
      image_tag url, loading: "lazy", class: "submission-file-full hidden"
    end
  end

  def submission_file_data_attributes(submission_file)
    {
      id: submission_file.id,
      width: submission_file.width,
      height: submission_file.height,
      compare_label: "#{submission_file.site.display_name} #{submission_file.width}x#{submission_file.height} #{number_to_human_size(submission_file.size)}",
    }
  end
end
