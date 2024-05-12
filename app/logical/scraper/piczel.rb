# frozen_string_literal: true

module Scraper
  class Piczel < Base
    STATE = :from_id

    def initialize(artist_url)
      super
      @from_id = 999_999_999
    end

    def fetch_next_batch
      response = fetch_json("https://piczel.tv/api/users/#{url_identifier}/gallery?from_id=#{@from_id}")
      @from_id = response.pluck("id").min
      end_reached if response.size != 32
      response
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["description"]
      s.created_at = DateTime.parse submission["created_at"]

      s.add_file({
        url: submission["image"]["url"],
        created_at: s.created_at,
        identifier: submission["id"],
      })
      submission["images"]&.each do |entry|
        s.add_file({
          url: entry["image"]["url"],
          created_at: s.created_at,
          identifier: "plain_image#{entry['id']}",
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
