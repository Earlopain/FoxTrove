module Scraper
  class Weasyl < Base
    def init
      @nextid = nil
    end

    def enabled?
      Config.weasyl_apikey.present?
    end

    def fetch_next_batch
      url = "https://www.weasyl.com/api/users/#{@identifier}/gallery"
      response = HTTParty.get(
        url,
        headers: { "X-Weasyl-API-Key": Config.weasyl_apikey },
        query: {}.tap { |h| h[:nextid] = @nextid if @nextid }
      )
      # TODO: Error handling
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
        s.files.push({
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
  end
end
