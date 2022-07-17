# frozen_string_literal: true

module Scraper
  class Furaffinity < Base
    def init
      @page = 1
      @submission_cache = []
      @will_have_more = true
      @cookie_a, @cookie_b = Cache.fetch("furaffinity-cookies", 2.weeks) { fetch_cookies }
    end

    def self.enabled?
      Config.furaffinity_user.present? && Config.furaffinity_pass.present?
    end

    def fetch_next_batch
      if @submission_cache.empty?
        @submission_cache = get_submission_ids(@page)
        @page += 1
        @will_have_more = !@submission_cache.empty?
      end

      single_submission_id = @submission_cache.shift
      end_reached if @submission_cache.empty? && !@will_have_more
      # Will happen when the user has no submissions at all
      return [] if single_submission_id.nil?

      html = get_submission_html single_submission_id
      # Old(?) text submissions are returned when searching by type  art
      if html.at(".submission-area.submission-writing")
        []
      else
        time_string = html.css(".submission-id-container .popup_date").first.content.strip
        [
          {
            id: single_submission_id,
            title: html.css(".submission-title").first.content.strip,
            description: html.css(".submission-description").first.content.strip,
            created_at: DateTime.strptime(time_string, "%b %d, %Y %I:%M %p"),
            url: "https:#{html.css('.download a').first.attributes['href'].value}",
          },
        ]
      end
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission[:id]
      s.title = submission[:title]
      s.description = submission[:description]
      s.created_at = submission[:created_at]
      s.add_file({
        url: submission[:url],
        created_at: s.created_at,
        identifier: "",
      })
      s
    end

    # No api and usernames cannot be changed
    def fetch_api_identifier
      url_identifier
    end

    private

    def get_submission_ids(page)
      url = "https://www.furaffinity.net/search"
      response = HTTParty.post(url, {
        headers: headers,
        body: {
          "page": page,
          "q": "@lower #{url_identifier}",
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
      html = Nokogiri::HTML(response.body)
      # Searching for "@lower scale" returns results from blue-scale
      relevant_submissions = html.css("#browse-search figure").select do |element|
        # Remove _ from displayname, https://www.furaffinity.net/user/thesecretcave/ => The_Secret_Cave
        element.css("figcaption a")[1].content.downcase.delete("_") == url_identifier.downcase
      end
      relevant_submissions.map do |element|
        element.attributes["id"].value.split("-")[1]
      end
    end

    def get_submission_html(id)
      url = "https://www.furaffinity.net/view/#{id}"
      response = HTTParty.get(url, { headers: headers })
      Nokogiri::HTML(response.body)
    end

    def headers
      { Cookie: "a=#{@cookie_a}; b=#{@cookie_b}" }
    end

    def fetch_cookies
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://www.furaffinity.net/login"
        wait = Selenium::WebDriver::Wait.new(timeout: 10)

        wait.until { driver.find_element(css: "#login-form input[name='name']") }.send_keys Config.furaffinity_user
        driver.find_element(css: "#login-form input[name='pass']").send_keys Config.furaffinity_pass
        driver.find_element(id: "login-button").click

        cookie_a = wait.until { driver.cookie_value("a") }
        cookie_b = driver.cookie_value("b")
        [cookie_a, cookie_b]
      end
    end
  end
end
