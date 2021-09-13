class Site < ApplicationRecord
  has_many :artist_urls, inverse_of: :site
  has_many :artists, through: :artist_urls
  has_many :submissions, through: :artist_urls

  def artist_url_identifier_regex
    # Escape all characters
    # Annotated tokens must be used since they contain no characters with special meaning in regex
    # https://twitter.com/%<site_artist_identifier>s/ => https://twitter\.com/%<site_artist_identifier>s\/
    first_pass = Regexp.new Regexp.escape artist_url_format
    # Replace the identifier with the site specific regex and capture it
    # https://twitter\.com/%<site_artist_identifier>s\/ => https://twitter\.com/([a-zA-Z0-9_]{1,15})/
    first_pass_substituted = first_pass.source % { site_artist_identifier: "(?<artist_identifier>#{artist_identifier_regex})" }
    # Allow matching both https and http
    # https://twitter\.com/([a-zA-Z0-9_]{1,15})/ => https?://twitter\.com/([a-zA-Z0-9_]{1,15})/
    allow_http = first_pass_substituted.sub(/^https/, "https?")
    # Require that the match spans the whole line
    # https?://twitter\.com/([a-zA-Z0-9_]{1,15})/ => ^https?://twitter\.com/([a-zA-Z0-9_]{1,15})/$
    match_start_end = "^#{allow_http}$"
    Regexp.new match_start_end
  end
end
