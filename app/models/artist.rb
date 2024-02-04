# frozen_string_literal: true

class Artist < ApplicationRecord
  has_many :artist_urls, dependent: :destroy
  has_many :submissions, through: :artist_urls
  has_many :submission_files, through: :submissions

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, printable_string: true
  validates :name, length: { in: 1..64 }

  attr_accessor :url_string

  def add_artist_url(url)
    Artist.transaction do
      result = Sites.from_gallery_url url

      if !result
        errors.add(:url, " #{url} is not a supported url") unless result
        next
      elsif !result[:valid]
        errors.add(:identifier, "#{result[:identifier]} is not valid for #{result[:site].display_name}")
        next
      end

      artist_url = artist_urls.new(
        site_type: result[:site].site_type,
        url_identifier: result[:identifier],
        created_at_on_site: Time.current,
        about_on_site: "",
      )

      artist_url.save

      if artist_url.errors.any?
        errors.add(:base, "#{url} is not valid: #{artist_url.errors.full_messages.join(',')}")
        artist_urls.delete(artist_url)
        raise ActiveRecord::Rollback
      end

      artist_url
    end
  end

  def enqueue_all_urls
    artist_urls.each(&:enqueue_scraping)
  end

  def oldest_last_scraped_at
    scraper_urls = artist_urls.select(&:scraper_enabled?)
    return nil if scraper_urls.any? { |artist_url| artist_url.last_scraped_at.nil? }

    scraper_urls.map(&:last_scraped_at).min
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = all

        q = q.attribute_matches(params[:name], :name)
        q = q.join_attribute_matches(params[:url_identifier], artist_urls: :url_identifier)
        q = q.join_attribute_matches(params[:site_type], artist_urls: :site_type)
        q.order(id: :desc)
      end
    end
  end
end
