# frozen_string_literal: true

module Scraper
  class Itaku < Base
    def initialize(artist_url)
      super
      @page = "https://itaku.ee/api/galleries/images/?owner=#{api_identifier}&ordering=-date_added&page=1&page_size=100&date_range=&maturity_rating=SFW&maturity_rating=Questionable&maturity_rating=NSFW&visibility=PUBLIC&visibility=PROFILE_ONLY"
    end

    def fetch_next_batch
      ids = get_ids_from_page(@page)
      end_reached if @page.nil?
      get_details(ids)
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

    def get_details(ids)
      ids.map do |id|
        fetch_json("https://itaku.ee/api/galleries/images/#{id}/")
      end
    end
  end
end
