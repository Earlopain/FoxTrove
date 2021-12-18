class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, optional: true, class_name: "User"
  belongs_to :site
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission"

  validates :identifier_on_site, uniqueness: { scope: :site_id, case_sensitive: false }
end
