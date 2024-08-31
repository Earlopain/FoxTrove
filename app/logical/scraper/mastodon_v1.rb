module Scraper
  # https://docs.joinmastodon.org/
  class MastodonV1 < Base
    STATE = :max_id
    MAX_LIMIT = 40

    def initialize(artist_url)
      super
      @max_id = nil
    end

    def domain
      raise NotImplementedError
    end

    def access_token
      raise NotImplementedError
    end

    def fetch_next_batch
      response = make_request("/accounts/#{api_identifier}/statuses", max_id: @max_id, limit: MAX_LIMIT, only_media: true, exclude_reblogs: true)
      oldest_entry = response.min_by { |entry| DateTime.parse(entry["created_at"]).strftime("%s").to_i }
      @max_id = oldest_entry&.dig("id")
      end_reached if response.count != MAX_LIMIT
      response
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = ""
      s.description = submission["content"]
      created_at = DateTime.parse submission["created_at"]
      s.created_at = created_at

      submission["media_attachments"].each do |media_attachment|
        next if %w[image gifv video].exclude? media_attachment["type"]

        s.add_file({
          url: media_attachment["url"],
          created_at: created_at,
          identifier: media_attachment["id"],
        })
      end
      s
    end

    def fetch_api_identifier
      response = make_request("/accounts/search", q: "#{url_identifier}@#{domain}")
      account = response[0]
      account["id"] if account&.dig("acct")&.casecmp? url_identifier
    end

    private

    def make_request(path, **query_params)
      url = "https://#{domain}/api/v1#{path}"
      fetch_json(url, params: query_params, headers: { Authorization: "Bearer #{access_token}" })
    end
  end
end
