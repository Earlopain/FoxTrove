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

  def icon_url(site_type)
    url = EsbuildManifest["#{site_type}.png"]
    tag.span(class: "site-icon", style: "--icon: url(#{url});")
  end

  def artist_url_icon(artist_url)
    icon = icon_url(artist_url.site_type)
    link_to(icon, gallery_url(artist_url), title: "#{artist_url.site.display_name} - #{artist_url.unescaped_url_identifier}")
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

  def scraper_status(artist_url)
    if job_stats.scraping_now.include?(artist_url.id)
      details = artist_url.scraper_status.except("started_at")
      extra = ": #{details.to_json}" if details.present?
      "Scraping now#{extra}"
    elsif job_stats.scraping_queued.key?(artist_url.id)
      "Scraping Queued"
    else
      "Idle"
    end
  end
end
