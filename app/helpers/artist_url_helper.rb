# frozen_string_literal: true

module ArtistUrlHelper
  def gallery_url(artist_url)
    artist_url.site.gallery_url(artist_url.url_identifier)
  end

  def submission_url(submission)
    submission.artist_url.site.submission_url(submission)
  end

  def site_types_collection
    Sites::ALL.map { |site| [site.display_name, site.enum_value] }.sort
  end

  def site_icon(artist_url)
    icon = tag.span(class: artist_url.site.icon_class)
    link_to tag.span(icon), gallery_url(artist_url), title: "#{artist_url.site.display_name} - #{artist_url.url_identifier}"
  end
end
