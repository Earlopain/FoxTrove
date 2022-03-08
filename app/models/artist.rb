class Artist < ApplicationRecord
  belongs_to_creator
  has_many :artist_urls, dependent: :destroy
  has_many :submissions, through: :artist_urls
  has_many :submission_files, through: :submissions

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, printable_string: true
  validates :name, length: { in: 1..64 }

  attr_accessor :url_string

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = all

        q.attributes_matching([:name], params)
        q.order(id: :desc)
      end
    end
  end
end
