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
      url = "https://www.weasyl.com/api/users/#{@url_identifier}/gallery"
      response = HTTParty.get(
        url,
        headers: { "X-Weasyl-API-Key": Config.weasyl_apikey },
        query: {}.tap { |h| h[:nextid] = @nextid if @nextid },
      )
      json = JSON.parse(response.body)
      @nextid = json["nextid"]
      end_reached if @nextid.nil?
      json["submissions"].select { |s| s["subtype"] == "visual" && s["media"]["submission"].present? }
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["submitid"]
      s.title = submission["title"]
      # Only returned when doing individual requests for submissions
      s.description = ""
      created_at = extract_timestamp submission
      s.created_at = created_at

      submission["media"]["submission"].each do |entry|
        s.add_file({
          url: entry["url"],
          created_at: created_at,
          identifier: entry["mediaid"],
        })
      end
      s
    end

    def extract_timestamp(submission)
      DateTime.parse submission["posted_at"]
    end

    # Unfortunately the api doesn't seem to return this information
    def fetch_api_identifier
      response = HTTParty.get("https://www.weasyl.com/~#{@url_identifier}", headers: { "X-Weasyl-API-Key": Config.weasyl_apikey })
      html = Nokogiri::HTML(response.body)
      html.at("#user-shouts .comment-form input[name='userid']")&.attribute("value")&.value
    end
  end
end
