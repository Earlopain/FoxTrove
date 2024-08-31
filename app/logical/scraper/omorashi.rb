module Scraper
  class Omorashi < BufferedScraper
    STATE = :page

    def initialize(artist_url)
      super
      @page = 1
    end

    def fetch_next_batch
      single_submission_url = fetch_from_batch { get_from_page(@page) }

      return [] if single_submission_url.nil?

      [get_submission_details(single_submission_url)]
    end

    def update_state
      @page += 1
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission[:identifier]
      s.title = submission[:title]
      s.description = submission[:description]
      s.created_at = submission[:created_at]
      s.add_file({
        url: submission[:url],
        created_at: s.created_at,
        identifier: s.identifier,
      })
      s
    end

    # The numeric part doesn't change and the slug is irrelevant
    def fetch_api_identifier
      url_identifier.sub(/-.*/, "")
    end

    private

    def get_from_page(page)
      response = client.get("https://www.omorashi.org/profile/#{url_identifier}/content/page/#{page}/?type=gallery_image", should_raise: false)
      if response.status == 303
        []
      else
        response.raise_unless_ok
        html = Nokogiri::HTML(response.body.to_s)
        html.css("a.ipsImageBlock__main").pluck("href")
      end
    end

    def get_submission_details(url)
      html = fetch_html(url)
      id = html.at_xpath("//body")["data-pageid"]
      {
        identifier: id,
        title: html.at_css(".ipsType_pageTitle span").text,
        description: "",
        created_at: DateTime.parse(html.at_css("section[data-role=imageInfo] time")["datetime"]),
        url: "https://www.omorashi.org/gallery/image/#{id}--/?do=download",
      }
    end
  end
end
