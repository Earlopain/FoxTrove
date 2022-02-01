module Scraper
  class Furrynetwork < Base
    PER_REQUEST = 72

    def init
      # This whole thing is very brittle and may break at any moment
      @bearer_token = Cache.fetch("furrynetwork-token", 55.minutes) do
        SeleniumWrapper.driver do |driver|
          driver.navigate.to "https://furrynetwork.com/login"
          driver.manage.window.maximize
          driver.find_element(id: "email").send_keys Config.furrynetwork_user
          driver.find_element(id: "password").send_keys Config.furrynetwork_pass
          driver.find_element(css: ".page--login__form button[type='submit']").click
          wait = Selenium::WebDriver::Wait.new(timeout: 10)
          wait.until { driver.find_element(class: "profile-switcher-menu") }
          driver.execute_script "return JSON.parse(window.localStorage.getItem('token')).access_token"
        end
      end
      @offset = 0
    end

    def enabled?
      Config.furrynetwork_user.present? && Config.furrynetwork_pass.present?
    end

    def fetch_next_batch
      json = make_request(@offset)
      end_reached if @offset + PER_REQUEST >= json["total"]
      @offset += PER_REQUEST
      json["hits"].map { |s| s["_source"] }
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["description"] || ""
      created_at = extract_timestamp submission
      s.created_at = created_at

      s.add_file({
        url: submission["images"]["original"],
        created_at: created_at,
        identifier: "",
      })
      s
    end

    def extract_timestamp(submission)
      DateTime.parse submission["created"]
    end

    private

    def make_request(offset)
      response = HTTParty.get("https://furrynetwork.com/api/search", {
        query: {
          size: PER_REQUEST,
          from: offset,
          character: @identifier,
          types: ["artwork"],
          sort: "published",
        },
        headers: {
          Authorization: "Bearer #{@bearer_token}",
        },
      })
      JSON.parse(response.body)
    end
  end
end