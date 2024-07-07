# frozen_string_literal: true

module Scraper
  class Cohost < Base
    STATE = :page

    def initialize(artist_url)
      super
      # Pages start at 0
      @page = 0
    end

    def fetch_next_batch
      input = {
        projectHandle: url_identifier,
        page: @page,
        options: {
          pinnedPostsAtTop: false,
          hideReplies: false,
          hideShares: true,
          hideAsks: true,
          viewingOnProjectPage: true,
        },
      }.to_json

      response = fetch_json("https://cohost.org/api/v1/trpc/posts.profilePosts", params: { input: input })
      @page += 1
      posts = response.dig("result", "data", "posts")
      end_reached if posts.blank?
      posts
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["postId"]
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

        s.add_file({
          url: block["attachment"]["fileURL"],
          created_at: s.created_at,
          identifier: block["attachment"]["attachmentId"],
        })
      end
      s
    end

    def fetch_api_identifier
      response = fetch_json("https://cohost.org/api/v1/project/#{url_identifier}")
      response["projectId"]
    end
  end
end
