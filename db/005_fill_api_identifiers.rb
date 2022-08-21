#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

site_type = ARGV[0]
raise StandardError, "Must provide a site type" unless site_type

ArtistUrl.where(api_identifier: nil, site_type: site_type).find_each do |artist_url|
  puts artist_url.url_identifier
  scraper = Sites.from_enum(site_type).new_scraper(artist_url)
  artist_url.update(api_identifier: scraper.fetch_api_identifier)
end
