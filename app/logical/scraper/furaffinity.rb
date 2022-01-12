
module Scraper
  class Furaffinity < Base
    def init
      @page = 1
    end

    def enabled?
      Config.furaffinity_cookie_a.present? && Config.furaffinity_cookie_b.present?
    end

    def fetch_next_batch
      submission_ids = get_submission_ids(@page)
      @page += 1
      end_reached if submission_ids.empty?
      submission_ids.map do |id|
        html = get_submission_html id
        time_string = html.css(".submission-id-container .popup_date").first.content.strip
        {
          id: id,
          title: html.css(".submission-title").first.content.strip,
          description: html.css(".submission-description").first.content.strip,
          created_at: DateTime.strptime(time_string, "%b %d, %Y %I:%M %p"),
          url: "https:#{html.css('.download a').first.attributes['href'].value}",
        }
      end
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission[:id]
      s.title = submission[:title]
      s.description = submission[:description]
      created_at = extract_timestamp submission
      s.created_at = created_at
      s.files.push({
        url: submission[:url],
        created_at: created_at,
        identifier: "",
      })
      s
    end

    def extract_timestamp(submission)
      submission[:created_at]
    end

    private

    def get_submission_ids(page)
      url = "https://www.furaffinity.net/search"
      response = HTTParty.post(url, {
        headers: headers,
        body: {
          "page": page,
          "q": "@lower #{@identifier}",
          "order-by": "date",
          "order-direction": "desc",
          "range": "all",
          "rating-general": "on",
          "rating-mature": "on",
          "rating-adult": "on",
          "type-art": "on",
          "mode": "extended",
        },
      })
      # TODO: Error handling
      html = Nokogiri::HTML(response.body)
      html.css("#browse-search figure").map do |element|
        element.attributes["id"].value.split("-")[1]
      end
    end

    def get_submission_html(id)
      url = "https://www.furaffinity.net/view/#{id}"
      response = HTTParty.get(url, { headers: headers })
      Nokogiri::HTML(response.body)
    end

    def headers
      { "Cookie": "a=#{Config.furaffinity_cookie_a}; b=#{Config.furaffinity_cookie_b}" }
    end
  end
end
