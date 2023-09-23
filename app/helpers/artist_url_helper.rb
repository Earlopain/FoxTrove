# frozen_string_literal: true

module ArtistUrlHelper
  def gallery_url(artist_url)
    artist_url.site.gallery_url(artist_url.unescaped_url_identifier)
  end

  def submission_url(submission)
    submission.artist_url.site.submission_url(submission)
  end

  def site_types_collection
    Sites.definitions.map { |definitions| [definitions.display_name, definitions.enum_value] }.sort
  end

  def site_icon(artist_url)
    icon = tag.span(class: artist_url.site.icon_class)
    link_to tag.span(icon), gallery_url(artist_url), title: "#{artist_url.site.display_name} - #{artist_url.unescaped_url_identifier}"
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
