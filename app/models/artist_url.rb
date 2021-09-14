class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, class_name: "Account"
  belongs_to :site
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission"

  def self.parse(url)
    site, regex = get_matching_site_and_regex url
    return nil if site.nil?

    matches = regex.match url
    # This shouldn't happen since we definitely already matched in get_matching_site
    return nil if matches[:artist_identifier].nil?

    {
      site: site,
      artist_identifier: matches[:artist_identifier],
    }
  end

  def self.get_matching_site_and_regex(url)
    Site.find_each.each do |site|
      regex = site.matching_regex url
      return [site, regex] if regex
    end
  end
end
