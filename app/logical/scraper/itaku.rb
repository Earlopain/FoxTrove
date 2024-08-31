module Scraper
  class Itaku < BufferedScraper
    STATE = :page

    def initialize(artist_url)
      super
      @page = "https://itaku.ee/api/galleries/images/?owner=#{api_identifier}&ordering=-date_added&page=1&page_size=100&date_range=&maturity_rating=SFW&maturity_rating=Questionable&maturity_rating=NSFW&visibility=PUBLIC&visibility=PROFILE_ONLY&visibility=UNLISTED"
    end

    def fetch_next_batch
      single_id = fetch_from_batch do
        if @page.nil?
          []
        else
          get_ids_from_page(@page)
        end
      end
      return [] if single_id.nil?

      [fetch_json("https://itaku.ee/api/galleries/images/#{single_id}/")]
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["description"]
      s.created_at = DateTime.parse submission["date_added"]

      file_url = if submission["video"].present?
                   submission["video"]["video"]
                 else
                   submission["image"]
                 end

      s.add_file({
        url: file_url,
        created_at: s.created_at,
        identifier: submission["id"],
      })
      s
    end

    def fetch_api_identifier
      response = fetch_json("https://itaku.ee/api/user_profiles/#{url_identifier}/")
      response["owner"]
    end

    private

    def get_ids_from_page(page)
      response = fetch_json(page)
      @page = response["links"]["next"]
      response["results"].pluck("id")
    end
  end
end
