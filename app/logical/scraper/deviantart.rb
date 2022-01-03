module Scraper
  class Deviantart < Base
    API_PREFIX = "https://www.deviantart.com/api/v1/oauth2".freeze

    def init
      # Tokens seem to expire after one hour
      @access_token = Cache.fetch("deviantart-token", 55.minutes) do
        fetch_access_token
      end
      @next_offset = nil
    end

    def enabled?
      Config.deviantart_client_id.present? && Config.deviantart_client_secret.present?
    end

    def fetch_next_batch
      json = make_api_call("gallery/allgallery/all", {
        username: @identifier,
        limit: 24,
        mature_content: true,
        offset: @next_offset,
      })
      end_reached unless json["has_more"]
      @next_offset = json["next_offset"]
      submissions = json["results"]
      add_downloadable submissions
    end

    def to_submission(submission)
      s = Submission.new
      # Extract number from https://www.deviantart.com/kenket/art/Rowdy-829623906
      s.identifier = submission["url"].match(/-([0-9]*)$/)[1]
      s.title = submission["title"]
      # FIXME: Title is only available when doing deviation/{deviationid}?expand=deviation.fulltext
      s.description = ""
      created_at = extract_timestamp submission
      s.created_at = created_at
      s.files.push({
        url: submission["download"] ? submission["download"]["src"] : submission["content"]["src"],
        created_at: created_at,
        identifier: "",
      })
      s
    end

    def extract_timestamp(submission)
      DateTime.strptime(submission["published_time"], "%s")
    end

    private

    def add_downloadable(submissions)
      submissions.map do |submission|
        # submission["content"]["filesize"] != submission["download_filesize"] doesn't work, since
        # content filesize seems to be the download file size for some reason.
        if submission["is_downloadable"]
          download_json = make_api_call("deviation/download/#{submission['deviationid']}")
          submission["download"] = download_json
          submission
        end
        submission
      end
    end

    def make_api_call(endpoint, query = {})
      response = HTTParty.get("#{API_PREFIX}/#{endpoint}", {
        query: {
          access_token: @access_token,
          **query,
        },
        headers: {
          "dA-minor-version": "20210526",
        },
      })
      # TODO: Error handlings
      JSON.parse(response.body)
    end

    def fetch_access_token
      response = HTTParty.get("https://www.deviantart.com/oauth2/token", query: {
        grant_type: "client_credentials",
        client_id: Config.deviantart_client_id,
        client_secret: Config.deviantart_client_secret,
      })
      # TODO: Error handling
      JSON.parse(response.body)["access_token"]
    end
  end
end
