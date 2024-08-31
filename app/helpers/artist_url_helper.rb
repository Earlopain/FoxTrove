module ArtistUrlHelper
  def gallery_url(artist_url)
    artist_url.site.gallery_url(artist_url.unescaped_url_identifier)
  end

  def submission_url(submission)
    submission.artist_url.site.submission_url(submission)
  end

  def site_types_collection
    Sites.definitions.map { |definition| [definition.display_name, definition.site_type] }.sort
  end

  def site_icon(artist_url, &)
    # NOTE: Would be neat to be able to use attr here but no browser supports this at the moment
    icon_index = ArtistUrl.site_types[artist_url.site_type]
    icon = tag.span(class: "site-icon", style: "--icon-index: #{icon_index};")
    icon_link = link_to(icon, gallery_url(artist_url), title: "#{artist_url.site.display_name} - #{artist_url.unescaped_url_identifier}")
    text = tag.span(capture(&), class: "site-icon-text") if block_given?
    tag.span(icon_link + text, class: "site-icon-wrapper")
  end

  def ordered_artist_urls(artist)
    artist.artist_urls.sort_by do |artist_url|
      numeric_site_type = artist_url.class.site_types[artist_url.site_type]
      scraper_modifier = artist_url.scraper_enabled? ? 0 : 100
      numeric_site_type + scraper_modifier
    end
  end

  def last_scraped_at_text(artist_url)
    return "Never" unless artist_url.last_scraped_at

    artist_url.last_scraped_at
  end

  def scraper_status(artist_url, prefix: "")
    return "" if artist_url.scraper_status.blank?

    beginning = "#{prefix}: " if prefix.present?
    "#{beginning}#{artist_url.scraper_status.except('started_at').to_json}"
  end
end
