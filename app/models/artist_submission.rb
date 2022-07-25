# frozen_string_literal: true

class ArtistSubmission < ApplicationRecord
  belongs_to :artist_url
  has_one :artist, through: :artist_url
  has_many :submission_files, dependent: :destroy

  validates :identifier_on_site, uniqueness: { scope: :artist_url_id, case_sensitive: false }

  delegate :site, to: :artist_url

  def self.for_site_with_identifier(site:, identifier:)
    joins(:artist_url).find_by(identifier_on_site: identifier, artist_url: { site_type: site })
  end
end
