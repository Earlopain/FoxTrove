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

      build_artist_urls(parsed)
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
      parsed.each do |result|
        artist_url = artist_urls.build(
          site_type: result[:definition].site_type,
          url_identifier: result[:identifier],
          created_at_on_site: Time.current,
          about_on_site: "",
        )

        if result[:definition].scraper_enabled?
          scraper = result[:definition].new_scraper(artist_url)

          begin
            artist_url.api_identifier = scraper.fetch_api_identifier
          rescue HTTPX::HTTPError => e
            http_status = e.status
          end

          unless artist_url.api_identifier
            message = "#{result[:url]} is not valid: #{result[:identifier]} failed api lookup"
            message << " (#{Rack::Utils::HTTP_STATUS_CODES[http_status]})" if http_status
            errors.add(:base, message)
            next
          end
        end

        forward_artist_url_errors(artist_url, result[:url])
      end
    end

    def forward_artist_url_errors(artist_url, raw_url)
      return if artist_url.valid?

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
