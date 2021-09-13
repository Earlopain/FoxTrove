class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, class_name: "Account"
  belongs_to :site
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission"

  def self.parse(url)
    site = get_matching_site url
    return nil if site.nil?

    matches = site.artist_url_identifier_regex.match url
    # This shouldn't happen since we definatly already matched in get_matching_site
    return nil if matches[:artist_identifier].nil?

    {
      site: site,
      artist_identifier: matches[:artist_identifier],
    }
  end

  def self.get_matching_site(url)
    Site.find_each.filter do |site|
      url =~ site.artist_url_identifier_regex
    end.first
  end
end
