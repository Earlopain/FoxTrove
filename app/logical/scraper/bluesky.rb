module Scraper
  class Bluesky < Base
    STATE = :cursor

    def initialize(artist_url)
      super
      @cursor = nil
    end

    # https://docs.bsky.app/docs/api/app-bsky-feed-get-author-feed
    def fetch_next_batch
      response = fetch_json("https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed", params: {
        filter: "posts_with_media",
        limit: 100,
        actor: api_identifier,
        cursor: @cursor,
      })
      @cursor = response["cursor"]
      end_reached unless @cursor

      response["feed"].pluck("post")
    end

    def to_submission(submission)
      record = submission["record"]
      s = Submission.new
      s.identifier = submission["cid"]
      s.title = ""
      s.description = record["text"]
      s.created_at = DateTime.parse(record["createdAt"])

      record.dig("embed", "images")&.pluck("image")&.each do |image|
        image_cid = image["ref"]["$link"]
        s.add_file({
          url: "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=#{api_identifier}&cid=#{image_cid}",
          created_at: s.created_at,
          identifier: image_cid,
        })
      end
      s
    end

    # https://docs.bsky.app/docs/api/app-bsky-actor-get-profile
    def fetch_api_identifier
      response = fetch_json("https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{url_identifier}")
      response["did"]
    end
  end
end
