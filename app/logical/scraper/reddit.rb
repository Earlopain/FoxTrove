module Scraper
  # https://www.reddit.com/dev/api/
  class Reddit < Base
    STATE = "after"

    def initialize(artist_url)
      super
      @after = nil
    end

    def fetch_next_batch
      response = make_request("/user/#{url_identifier}/submitted.json", {
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
      entries.pluck("data").select { |e| e["domain"] == "i.redd.it" || (e["domain"] == "reddit.com" && e["media_metadata"].present?) }
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = ""
      s.created_at = DateTime.strptime(submission["created"].to_s, "%s")

      if submission["domain"] == "i.redd.it"
        s.add_file({
          url: submission["url"],
          created_at: s.created_at,
          identifier: "",
        })
      elsif submission["domain"] == "reddit.com" && submission["media_metadata"].present?
        submission["media_metadata"].each do |identifier, data|
          data["m"] = "image/jpeg" if data["m"] == "image/jpg"
          s.add_file({
            url: "https://i.redd.it/#{identifier}.#{Marcel::EXTENSIONS.invert[data['m']]}",
            created_at: s.created_at,
            identifier: identifier,
          })
        end
      end
      s
    end

    def fetch_api_identifier
      json = make_request("/user/#{url_identifier}/about.json")
      json.dig("data", "id")
    end

    def extend_client(client)
      client
        .plugin(:basic_auth)
        .with(headers: { "User-Agent": FRIENDLY_USER_AGENT }, origin: "https://oauth.reddit.com")
    end

    private

    def make_request(url, params = {})
      client.fetch_json(url, params: params, headers: {
        Authorization: "bearer #{access_token}",
      })
    end

    def access_token
      with_basic_auth = client.basic_auth(Config.reddit_client_id, Config.reddit_client_secret)
      response = with_basic_auth.fetch_json("https://www.reddit.com/api/v1/access_token",
        method: :post,
        form: { grant_type: "client_credentials" },
      )
      response["access_token"]
    end
    cache(:access_token, 55.minutes)
  end
end
