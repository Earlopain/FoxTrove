module Scraper
  class Artstation < Base
    def init
      @page = 1
    end

    def self.enabled?
      true
    end

    def fetch_next_batch
      ids = get_ids_from_page(@page)
      end_reached if ids.count == 0
      @page += 1
      get_details(ids)
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["hash_id"]
      s.title = submission["title"]
      s.description = Rails::Html::FullSanitizer.new.sanitize submission["description"]
      created_at = extract_timestamp submission
      s.created_at = created_at

      submission["assets"].each do |asset|
        s.add_file({
          url: asset["image_url"],
          created_at: created_at,
          identifier: asset["id"],
        })
      end
      s
    end

    def extract_timestamp(submission)
      DateTime.parse submission["created_at"]
    end

    def fetch_api_identifier
      response = HTTParty.get("https://www.artstation.com/users/#{@identifier}/quick.json")
      return nil if response.code == 404

      JSON.parse(response.body)["id"]
    end

    private

    def get_ids_from_page(page)
      response = HTTParty.get("https://www.artstation.com/users/#{@identifier}/projects.json?page=#{page}")
      JSON.parse(response.body)["data"].map { |entry| entry["hash_id"] }
    end

    def get_details(ids)
      details = ids.map do |id|
        HTTParty.get("https://www.artstation.com/projects/#{id}.json")
      end
      # Remove any non-image assets
      details.map do |entry|
        entry["assets"] = entry["assets"].select { |asset| asset["asset_type"].in? %w[image cover] }
      end
      # Remove ids where there are no image assets
      details.reject do |entry|
        entry["assets"].count == 0
      end
    end
  end
end
