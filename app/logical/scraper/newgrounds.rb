# frozen_string_literal: true

module Scraper
  class Newgrounds < BufferedScraper
    COOKIE_NAME = "vmkIdu5l8m"

    def initialize(artist_url)
      super
      @page = 1
    end

    def self.state
      :page
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

      submission[:files].reverse.each_with_index do |url, index|
        s.add_file({
          url: url,
          created_at: s.created_at,
          identifier: index,
        })
      end
      s
    end

    def fetch_api_identifier
      html = fetch_html("https://#{url_identifier}.newgrounds.com/")
      html.at("#topsearch-elastic input[name='u']")&.attribute("value")&.value
    end

    private

    def get_from_page(page)
      url = "https://#{url_identifier}.newgrounds.com/art/page/#{page}"
      json = fetch_json(url, headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Cookie": "#{COOKIE_NAME}=#{fetch_cookie}",
      })
      if json["items"].empty? # Empty pages contain an array instead of an object here
        []
      else
        submissions = json["items"].keys.map { |year| json["items"][year] }.flatten
        submissions.map { |entry| Nokogiri::HTML(entry).css("a").first.attributes["href"].value }
      end
    end

    def get_submission_details(url) # rubocop:disable Metrics/CyclomaticComplexity
      html = fetch_html(url, headers: { cookie: "#{COOKIE_NAME}=#{fetch_cookie}" })
      media_object = html.at("[itemtype='https://schema.org/MediaObject']")
      image_urls = []
      if (image = media_object.at(".medium_image"))
        # Legacy single image submissions
        # https://www.newgrounds.com/art/view/kooriki/gina-ref
        image_urls << image.attributes["href"].value
      end

      # Multi-image submissions. New single image submissions also look like this
      # Comics don't have a href on this element
      # https://www.newgrounds.com/art/view/kooriki/early-bird-gets-the-wyrm
      image_urls += media_object.css("[data-action='view-image'][href]").map { |e| e.attributes["href"].value }

      # Comic submissions
      # https://www.newgrounds.com/art/view/ethandoesathing/legend-of-arcana-ch-1-pages
      image_data, = html.to_s.scan(/imageData = (\[[\s\S]*\]);/m).first
      if image_data
        image_urls += JSON.parse(image_data).pluck("image")
      end

      # Commentary images
      # https://www.newgrounds.com/art/view/kooriki/gina-at-the-beach
      image_urls += media_object.css("#author_comments img[data-smartload-src]").map { |e| e.attributes["data-smartload-src"].value }
      {
        identifier: url.split("/").pop,
        title: media_object.at("[itemprop='name']").content.strip,
        description: media_object.at("#author_comments")&.content&.strip || "",
        created_at: DateTime.parse(media_object.at("[itemprop='datePublished']").attributes["content"].value),
        files: image_urls,
      }
    end

    def fetch_cookie
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://www.newgrounds.com/passport"
        driver.wait_for_element(css: "input[name='username']").send_keys Config.newgrounds_user
        driver.find_element(css: "input[name='password']").send_keys Config.newgrounds_pass
        driver.find_element(css: "button.PassportLoginBtn").click
        driver.wait_for_cookie(COOKIE_NAME)
      end
    end
    cache(:fetch_cookie, 2.weeks)
  end
end
