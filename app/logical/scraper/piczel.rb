module Scraper
  class Piczel < Base
    STATE = "page"

    def initialize(artist_url)
      super
      @page = 1
    end

    def fetch_next_batch
      response = fetch_json("https://piczel.tv/api/users/#{url_identifier}/gallery?page=#{@page}")
      @page += 1
      end_reached unless response.dig("meta", "next_page")
      response["data"]
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["description"]
      s.created_at = DateTime.parse submission["created_at"]

      if submission["images"]
        submission["images"]&.each_with_index do |entry, index|
          s.add_file({
            url: entry["image"]["url"],
            created_at: s.created_at,
            identifier: "#{submission['id']}_#{index}",
          })
        end
      else
        s.add_file({
          url: submission["image"]["url"],
          created_at: s.created_at,
          identifier: submission["id"],
        })
      end
      s
    end

    def fetch_api_identifier
      response = fetch_json("https://piczel.tv/api/users/#{url_identifier}?friendly=1")
      response["id"]
    end
  end
end
