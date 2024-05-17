# frozen_string_literal: true

module Scraper
  class Artstation < BufferedScraper
    STATE = :page

    def initialize(artist_url)
      super
      @page = 1
    end

    def fetch_next_batch
      single_id = fetch_from_batch { get_ids_from_page(@page) }
      return [] if single_id.nil?

      [get_details(single_id)].compact
    end

    def update_state
      @page += 1
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["hash_id"]
      s.title = submission["title"]
      s.description = Rails::Html::FullSanitizer.new.sanitize submission["description"]
      s.created_at = DateTime.parse(submission["created_at"])

      submission["assets"].each do |asset|
        s.add_file({
          url: asset["image_url"],
          created_at: s.created_at,
          identifier: asset["id"],
        })
      end
      s
    end

    def fetch_api_identifier
      response = make_request("/users/#{url_identifier}/quick.json")
      response["id"]
    rescue JSON::ParserError
      nil
    end

    private

    def get_ids_from_page(page)
      response = make_request("/users/#{url_identifier}/projects.json?page=#{page}")
      response["data"].pluck("hash_id")
    end

    def get_details(id)
      json = make_request("/projects/#{id}.json")
      # Remove any non-image assets
      json["assets"] = json["assets"].select { |asset| asset["asset_type"].in? %w[image cover] }
      json if json["assets"].count > 0
    end

    # FIXME: Figure out a way to do this without selenium
    def make_request(path)
      fetch_json_selenium("https://www.artstation.com#{path}")
    end
  end
end
