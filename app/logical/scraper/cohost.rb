module Scraper
  class Cohost < Base
    STATE = :page

    def initialize(artist_url)
      super
      # Pages start at 0
      @page = 0
      @enqueue_delay = 0
    end

    # Links are fetched with a bogus timestamp, they redirect to the correct one.
    # The Wayback Machine has a pretty harsh limit on the rate that connections can be
    # established, so we explicitly use a persistent connection for the scraper and queue
    # file downloads well into the future.
    def extend_client(client)
      client.plugin(:follow_redirects).plugin(:persistent)
    end

    def fetch_next_batch
      input = {
        projectHandle: url_identifier,
        page: @page,
        options: {
          pinnedPostsAtTop: true,
          hideReplies: false,
          hideShares: true,
          hideAsks: false,
          viewingOnProjectPage: true,
        },
      }.to_json

      response = fetch_json(to_wayback("https://cohost.org/api/v1/trpc/posts.profilePosts?#{input.to_query('input')}"))
      @page += 1
      posts = response.dig("result", "data", "posts")
      end_reached if posts.blank?
      posts
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["filename"]
      s.title = submission["headline"]
      s.description = submission["plainTextBody"]
      s.created_at = DateTime.parse(submission["publishedAt"])

      # kind: audio image
      # grep for https://staging.cohostcdn.org/attachment in markdown

      submission["blocks"].each do |block|
        # markdown is another type
        next if block["type"] != "attachment"
        # audio is another type. Gifs are images
        next if block["attachment"]["kind"] != "image"

        @enqueue_delay += 15 # 10 is too little
        s.add_file({
          url: to_wayback(block["attachment"]["fileURL"]),
          created_at: s.created_at,
          identifier: block["attachment"]["attachmentId"],
          delay: @enqueue_delay.seconds,
        })
      end
      s
    end

    # https://wiki.archiveteam.org/index.php?title=Internet_Archive
    # This does not use https://archive.org/wayback/available because that
    # is totally unrealiable and occasionally returns no snapshot (rate limit?).
    # Using it would be nice since it filters out redirects and other non-successful
    # status codes. Instead, use the timestamp when scraping started, that should
    # prevent catching snapshots in the future where the site now redirects.
    def to_wayback(path)
      "https://web.archive.org/web/20241100000000id_/#{path}"
    end

    def fetch_api_identifier
      url_identifier
    end
  end
end
