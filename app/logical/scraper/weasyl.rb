# frozen_string_literal: true

module Scraper
  # https://projects.weasyl.com/weasylapi/
  class Weasyl < Base
    def init
      @nextid = nil
    end

    def self.enabled?
      Config.weasyl_apikey.present?
    end

    def fetch_next_batch
      url = "https://www.weasyl.com/api/users/#{url_identifier}/gallery"
      response = fetch_json(url,
        headers: { "X-Weasyl-API-Key": Config.weasyl_apikey },
        query: {}.tap { |h| h[:nextid] = @nextid if @nextid },
      )
      @nextid = response["nextid"]
      end_reached if @nextid.nil?
      response["submissions"].select { |s| s["subtype"] == "visual" && s["media"]["submission"].present? }
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["submitid"]
      s.title = submission["title"]
      # Only returned when doing individual requests for submissions
      s.description = ""
      s.created_at = DateTime.parse submission["posted_at"]

      submission["media"]["submission"].each do |entry|
        s.add_file({
          url: entry["url"],
          created_at: s.created_at,
          identifier: entry["mediaid"],
        })
      end
      s
    end

    # Unfortunately the api doesn't seem to return this information
    def fetch_api_identifier
      response = fetch_html("https://www.weasyl.com/~#{url_identifier}", headers: { "X-Weasyl-API-Key": Config.weasyl_apikey })
      html = Nokogiri::HTML(response.body)
      html.at("#user-shouts .comment-form input[name='userid']")&.attribute("value")&.value
    end
  end
end
