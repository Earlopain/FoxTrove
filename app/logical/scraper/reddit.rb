module Scraper
  # https://www.reddit.com/dev/api/
  class Reddit < Base
    def init
      @access_token = Cache.fetch("reddit-token", 55.minutes) do
        response = HTTParty.post(
          "https://www.reddit.com/api/v1/access_token",
          body: "grant_type=client_credentials",
          basic_auth: { username: Config.reddit_client_id, password: Config.reddit_client_secret },
          headers: { "Content-Type": "application/x-www-form-urlencoded", "User-Agent": "reverser.0.1 by earlopain" }
        )
        json = JSON.parse response.body
        json["access_token"]
      end
      @after = nil
    end

    def self.enabled?
      Config.reddit_client_id.present? && Config.reddit_client_secret.present?
    end

    def fetch_next_batch
      response = make_request("https://oauth.reddit.com/user/#{@identifier}/submitted.json", {
        after: @after,
        limit: 100,
        sort: "new",
        show: "all",
      })
      @after = response["data"]["after"]
      end_reached if @after.nil?
      entries = response["data"]["children"]
      # Gifs are not videos
      # TODO: videos are not a single file, but a dash stream
      # TODO: figure out if stuff can still be searched for, but images are gone
      entries.map{ |e| e["data"] }.select { |e| e["domain"] == "i.redd.it" || (e["domain"] == "reddit.com" && e["media_metadata"].present?) }
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = ""
      created_at = extract_timestamp submission
      s.created_at = created_at

      if submission["domain"] == "i.redd.it"
        s.add_file({
          url: submission["url"],
          created_at: created_at,
          identifier: "",
        })
      elsif submission["domain"] == "reddit.com" && submission["media_metadata"].present?
        submission["media_metadata"].each do |identifier, data|
          data["m"] = "image/jpeg" if data["m"] == "image/jpg"
          s.add_file({
            url: "https://i.redd.it/#{identifier}.#{Marcel::EXTENSIONS.invert[data['m']]}",
            created_at: created_at,
            identifier: identifier,
          })
        end
      end
      s
    end

    def extract_timestamp(submission)
      DateTime.strptime(submission["created"].to_s, "%s")
    end

    private

    def make_request(url, query = {})
      response = HTTParty.get(url, {
        query: query,
        headers: { "User-Agent": "reverser.0.1 by earlopain", "Authorization": "bearer #{@access_token}" },
      })
      # TODO: Error handling
      JSON.parse(response.body)
    end
  end
end
