class Artist < ApplicationRecord
  has_many :artist_urls, dependent: :destroy
  has_many :submissions, through: :artist_urls
  has_many :submission_files, through: :submissions

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, printable_string: true
  validates :name, length: { in: 1..64 }

  attr_accessor :url_string

  concerning :UrlParsing do
    def add_artist_urls
      parsed = parse_urls(url_string)
      return if errors.any?

      new_artist_urls = build_artist_urls(parsed)
      return if errors.any?

      artist_urls.concat(new_artist_urls)
    end

    private

    def parse_urls(url_string)
      url_string.lines.map(&:strip).compact_blank.map do |url|
        Sites.from_gallery_url(url).tap do |result|
          case result[:type]
          when :unsupported
            errors.add(:base, "#{url} is not a supported url")
          when :invalid
            errors.add(:base, "#{result[:identifier]} is not valid for #{result[:definition].display_name}")
          end
        end
      end
    end

    def build_artist_urls(parsed)
      parsed.map do |result|
        artist_url = ArtistUrl.new(
          # This will be appended to the relation, so it seems
          # unessesary to set here. But we need it to pass validations.
          artist: self,
          site_type: result[:definition].site_type,
          created_at_on_site: Time.current,
          about_on_site: "",
        )
        if artist_url.scraper_enabled?
          artist_url.fetch_identifier!(result)
        else
          artist_url.url_identifier = result[:identifier]
          artist_url.api_identifier = result[:identifier] if result[:type] == :api
        end
        forward_artist_url_errors(artist_url, result[:url])
        artist_url
      end
    end

    def forward_artist_url_errors(artist_url, raw_url)
      return if artist_url.errors.none? && artist_url.valid?

      errors.add(:base, "#{raw_url} is not valid: #{artist_url.errors.full_messages.join(', ')}")
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
