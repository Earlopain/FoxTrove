module Scraper
  # https://projects.weasyl.com/weasylapi/
  class Weasyl < Base
    STATE = :nextid

    def initialize(artist_url)
      super
      @nextid = nil
    end

    def fetch_next_batch
      url = "https://www.weasyl.com/api/users/#{url_identifier}/gallery"
      json = fetch_json(url,
        headers: { "X-Weasyl-API-Key": Config.weasyl_apikey },
        params: {}.tap { |h| h[:nextid] = @nextid if @nextid },
      )
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
      html = fetch_html("https://www.weasyl.com/~#{url_identifier}", headers: { "X-Weasyl-API-Key": Config.weasyl_apikey })
      shoutbox_id = html.at("#user-shouts .comment-form input[name='userid']")&.attribute("value")&.value
      # Unverified accounts can't shout: Your account has to be verified to comment
      ignore_id = html.at("form[name=ignoreuser] input[name='userid']")&.attribute("value")&.value
      shoutbox_id || ignore_id
    end
  end
end
