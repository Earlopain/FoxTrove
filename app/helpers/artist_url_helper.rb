module ArtistUrlHelper
  def link_for_artist_url(artist_url)
    Addressable::Template.new("https://#{artist_url.site.artist_url_templates.first}").expand(site_artist_identifier: artist_url.identifier_on_site).to_s
  end
end
