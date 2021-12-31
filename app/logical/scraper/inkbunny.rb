module Scraper
  # https://wiki.inkbunny.net/wiki/API
  class Inkbunny < Base
    def init
      @sid = Cache.fetch("inkbunny-sid", 1.hour) do
        fetch_sid
      end
      @rid = nil
      @page = 1
    end

    def enabled?
      Config.inkbunny_user.present? && Config.inkbunny_pass.present?
    end

    def fetch_next_batch
      json = if @rid
               search_mode2
             else
               search_mode1
             end
      end_reached if json["pages_count"] == json["page"]
      submission_ids = json["submissions"].map { |entry| entry["submission_id"] }
      submissions = submission_details(submission_ids).reject { |submission| submission["last_file_update_datetime"].nil? }
      end_reached if !@stop_marker.nil? && submissions.any? { |submission| DateTime.parse(submission["last_file_update_datetime"]).before? @stop_marker }
      @page += 1
      submissions
    end

    def to_submission(inkbunny_submission)
      s = Submission.new
      s.identifier = inkbunny_submission["submission_id"]
      s.title = inkbunny_submission["title"]
      s.description = inkbunny_submission["description"]
      s.created_at = DateTime.parse(inkbunny_submission["create_datetime"])

      inkbunny_submission["files"].each do |file|
        s.files.push({
          url: file["file_url_full"],
          created_at: DateTime.parse(file["create_datetime"]),
          identifier: file["file_id"],
        })
      end
      s
    end

    private

    def submission_details(submission_ids)
      url = "https://inkbunny.net/api_submissions.php"
      make_request(url, { submission_ids: submission_ids.join(","), show_description: "yes" })["submissions"]
    end

    def search_mode1
      url = "https://inkbunny.net/api_search.php"
      params = {
        get_rid: "yes",
        submission_ids_only: "yes",
        submissions_per_page: 100,
        username: @identifier,
        type: "1,2,3,4,5,8,9,13",
        orderby: "last_file_update_datetime",
      }
      json = make_request(url, params)
      @rid = json["rid"]
      json
    end

    def search_mode2
      url = "https://inkbunny.net/api_search.php"
      params = {
        submission_ids_only: "yes",
        submissions_per_page: 100,
        rid: @rid,
        page: @page,
      }
      make_request(url, params)
    end

    def make_request(url, query_params)
      HTTParty.get(url, query: {
        **query_params,
        sid: @sid,
      })
    end

    def fetch_sid
      response = make_request("https://inkbunny.net/api_login.php", {
        username: Config.inkbunny_user,
        password: Config.inkbunny_pass,
      })
      # TODO: Error handling
      JSON.parse(response.body)["sid"]
    end
  end
end
