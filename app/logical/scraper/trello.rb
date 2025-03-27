module Scraper
  # https://developer.atlassian.com/cloud/trello/rest
  class Trello < Base
    STATE = :before
    OPTIONAL_CONFIG_KEYS = %i[trello_key trello_token].freeze

    def initialize(artist_url)
      super
      @before = nil
    end

    def fetch_next_batch
      url = "https://api.trello.com/1/boards/#{api_identifier}/cards"
      json = fetch_json(url,
        params: {
          attachments: true,
          attachment_fields: "id,date,url",
          fields: "id,desc,shortLink,name",
          limit: 1000,
          sort: "-id",
          filter: "all",
          before: @before,
          key: Config.trello_key,
          token: Config.trello_token,
        },
      )
      @before = json.min_by { |c| to_unix(c["id"]) }&.[]("id")
      end_reached if json.length < 1000
      json.reject { |c| c["attachments"].empty? }
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["shortLink"]
      s.title = submission["name"]
      s.description = submission["desc"]
      s.created_at = DateTime.strptime(to_unix(submission["id"]).to_s, "%s")

      submission["attachments"].each do |entry|
        s.add_file({
          url: entry["url"],
          created_at: DateTime.parse(entry["date"]),
          identifier: entry["id"],
        })
      end
      s
    end

    def fetch_api_identifier
      url = "https://trello.com/b/#{url_identifier}.json"
      json = fetch_json(url, params: {
        actions: "none",
        cards: "none",
        fields: "id",
        labels: "none",
        lists: "none",
        key: Config.trello_key,
        token: Config.trello_token,
      })
      json["id"]
    end

    private

    def to_unix(id)
      id[0..7].to_i(16)
    end
  end
end
