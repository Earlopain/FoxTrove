# frozen_string_literal: true

module Scraper
  class Furaffinity < BufferedScraper
    def initialize(artist_url)
      super
      @page = 1
    end

    def self.state
      :page
    end

    def fetch_next_batch
      single_submission_id = fetch_from_batch { get_submission_ids(@page) }
      return [] if single_submission_id.nil?

      html = get_submission_html single_submission_id
      # Old(?) text submissions are returned when searching by type  art
      if html.at(".submission-area.submission-writing")
        []
      else
        [
          {
            id: single_submission_id,
            title: html.css(".submission-title").first.content.strip,
            description: html.css(".submission-description").first.content.strip,
            created_at: submission_timestamp(html),
            url: "https:#{html.css('.download a').first.attributes['href'].value}",
          },
        ]
      end
    end

    def update_state
      @page += 1
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

    def new_stop_marker
      query = SubmissionFile.joins(artist_submission: :artist_url).where(artist_submission: { artist_url: @artist_url })
      query.order(created_at_on_site: :desc).pick(:created_at_on_site)
    end

    private

    def get_submission_ids(page)
      html = fetch_html("https://www.furaffinity.net/search",
        method: :post,
        headers: headers,
        form: {
          "page": page,
          # Searches can't start with a dash, and can' contain ~
          # ~ can be substituted with - when searching
          "q": "@lower #{url_identifier.tr('~', '-').delete_prefix('-')}",
          "order-by": "date",
          "order-direction": "desc",
          "range": "all",
          "rating-general": "on",
          "rating-mature": "on",
          "rating-adult": "on",
          "type-art": "on",
          "mode": "extended",
        },
      )
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
      fetch_html("https://www.furaffinity.net/view/#{id}", headers: headers)
    end

    def submission_timestamp(html)
      element = html.css(".submission-id-container .popup_date").first
      begin
        # Full date format
        DateTime.strptime(element.content.strip, "%b %d, %Y %I:%M %p")
      rescue ArgumentError
        # Fuzzy date format
        DateTime.strptime(element.attribute("title").content.strip, "%b %d, %Y %I:%M %p")
      end
    end

    def headers
      cookie_a, cookie_b = fetch_cookies
      { Cookie: "a=#{cookie_a}; b=#{cookie_b}" }
    end

    def fetch_cookies
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://www.furaffinity.net/login"

        driver.wait_for_element(css: "#login-form input[name='name']").send_keys Config.furaffinity_user
        driver.find_element(css: "#login-form input[name='pass']").send_keys Config.furaffinity_pass
        driver.find_element(id: "login-button").click

        cookie_a = driver.wait_for_cookie("a")
        cookie_b = driver.cookie_value("b")
        [cookie_a, cookie_b]
      end
    end
    cache(:fetch_cookies, 2.weeks)
  end
end
