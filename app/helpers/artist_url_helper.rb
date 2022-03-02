module ArtistUrlHelper
  def gallery_url(artist_url)
    artist_url.site.gallery_url(artist_url.url_identifier)
  end

  def submission_url(submission)
    submission.artist_url.site.submission_url(submission)
  end

  def display_name(artist_url)
    artist_url.site.display_name
  end
end
