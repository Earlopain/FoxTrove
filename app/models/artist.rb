class Artist < ApplicationRecord
  has_many :artist_urls, dependent: :destroy
  has_many :submissions, through: :artist_urls
  has_many :submission_files, through: :submissions

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, printable_string: true
  validates :name, length: { in: 1..64 }

  attr_accessor :url_string

  def update_all_iqdb
    artist_urls.each do |artist_url|
      artist_url.submissions.each do |submission|
        submission.submission_files.each do |file|
          E6IqdbQueryWorker.perform_async(file.id, false)
        end
      end
    end
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = all

        q = q.attribute_matches(params[:name], :name)
        q = q.attribute_matches(params[:url_identifier], artist_urls: :url_identifier)
        q.order(id: :desc)
      end
    end
  end
end
