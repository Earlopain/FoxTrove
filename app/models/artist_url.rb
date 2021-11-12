class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, class_name: "User"
  belongs_to :site
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission"

  def self.parse(url)
    uri = Addressable::URI.parse url
    Site.find_each.each do |site|
      match = site.matching_template_and_result uri
      match[:site] = site if match
      match[:identifier_valid] = Regexp.new("^#{site.artist_identifier_regex}$").match? match[:site_artist_identifier] if match
      return match if match
    end
    nil
  end
end
