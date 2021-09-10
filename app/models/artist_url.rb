class ArtistUrl < ApplicationRecord
  belongs_to_creator
  belongs_to :approver, class_name: "Account"
  belongs_to :site
  belongs_to :artist
  has_many :submissions, class_name: "ArtistSubmission"
end
