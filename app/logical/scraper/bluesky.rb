module Scraper
  class Bluesky < Base
    STATE = "cursor"

    def initialize(artist_url)
      super
      @cursor = nil
    end

    # https://endpoints.bsky.app/#bluesky-app/tag/appbskyfeed/GET/xrpc/app.bsky.feed.getAuthorFeed
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
      s.identifier = submission["uri"].split("/").last
      s.title = ""
      s.description = record["text"]
      s.created_at = DateTime.parse(record["createdAt"])

      embed = record["embed"]
      case embed["$type"]
      when "app.bsky.embed.images"
        embed["images"]&.pluck("image")&.each do |image|
          image_cid = image["ref"]["$link"]
          add_cid(s, image_cid)
        end
      when "app.bsky.embed.video"
        cid = embed["video"]["ref"]["$link"]
        add_cid(s, cid)
      end

      s
    end

    # https://endpoints.bsky.app/#bluesky-app/tag/comatprotosync/GET/xrpc/com.atproto.sync.getBlob
    def add_cid(submission, cid)
      submission.add_file({
        url: "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=#{api_identifier}&cid=#{cid}",
        created_at: submission.created_at,
        identifier: cid,
      })
    end

    # https://endpoints.bsky.app/#bluesky-app/tag/appbskyactor/GET/xrpc/app.bsky.actor.getProfile
    def fetch_api_identifier
      response = fetch_json("https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{url_identifier}")
      response["did"]
    end

    def fetch_url_identifier
      response = fetch_json("https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=#{api_identifier}")
      response["handle"]
    end
  end
end
