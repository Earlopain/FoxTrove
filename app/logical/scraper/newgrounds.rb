# frozen_string_literal: true

module Scraper
  class Newgrounds < Base
    COOKIE_NAME = "vmkIdu5l8m"

    def initialize(artist_url)
      super
      @page = 1
      @submission_cache = []
      @will_have_more = true
    end

    def self.required_config_keys
      %i[newgrounds_user newgrounds_pass]
    end

    def self.state
      :page
    end

    def fetch_next_batch
      # Newgrounds has no api, searching basically only returns the url, nothing more.
      # Loading all html pages just to see if something new is bad, so it's buffered here, so that
      # it can be checked on each submission one after the other
      if @submission_cache.empty?
        response = get_from_page(@page)
        submissions = response["items"].keys.map { |year| response["items"][year] }.flatten
        @submission_cache = submissions.map { |entry| Nokogiri::HTML(entry).css("a").first.attributes["href"].value }
        @page += 1
        @will_have_more = response["load_more"].strip.present?
      end

      single_submission_url = @submission_cache.shift
      end_reached if @submission_cache.empty? && !@will_have_more
      [get_submission_details(single_submission_url)]
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission[:identifier]
      s.title = submission[:title]
      s.description = submission[:description]
      s.created_at = submission[:created_at]

      submission[:files].each_with_index do |url, index|
        s.add_file({
          url: url,
          created_at: s.created_at,
          identifier: index,
        })
      end
      s
    end

    def fetch_api_identifier
      response = fetch_html("https://#{url_identifier}.newgrounds.com/")
      html = Nokogiri::HTML(response.body)
      html.at("#topsearch-elastic input[name='u']")&.attribute("value")&.value
    end

    private

    def get_from_page(page)
      url = "https://#{url_identifier}.newgrounds.com/art/page/#{page}"
      response = fetch_json(url, headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Cookie": "#{COOKIE_NAME}=#{fetch_cookie}",
      })
      JSON.parse(response.body)
    end

    def get_submission_details(url)
      response = fetch_html(url, headers: { Cookie: "#{COOKIE_NAME}=#{fetch_cookie}" })
      html = Nokogiri::HTML(response.body)
      media_object = html.at("[itemtype='https://schema.org/MediaObject']")
      main_image_url = media_object.at(".image img").attributes["src"].value
      secondary_image_urls = media_object.css("#author_comments img[data-smartload-src]").map { |e| e.attributes["data-smartload-src"].value }
      {
        identifier: url.split("/").pop,
        title: media_object.at("[itemprop='name']").content.strip,
        description: media_object.at("#author_comments")&.content&.strip || "",
        created_at: DateTime.parse(media_object.at("[itemprop='datePublished']").attributes["content"].value),
        files: [main_image_url] + secondary_image_urls,
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
