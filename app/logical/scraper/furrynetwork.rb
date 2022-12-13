# frozen_string_literal: true

module Scraper
  class Furrynetwork < Base
    PER_REQUEST = 72
    API_PREFIX = "https://furrynetwork.com/api"

    def init
      @offset = 0
    end

    def self.enabled?
      Config.furrynetwork_user.present? && Config.furrynetwork_pass.present?
    end

    def fetch_next_batch
      json = make_request("/search", {
        size: PER_REQUEST,
        from: @offset,
        character: url_identifier,
        types: ["artwork"],
        sort: "published",
      })
      end_reached if @offset + PER_REQUEST >= json["total"]
      @offset += PER_REQUEST
      json["hits"].pluck("_source")
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["description"] || ""
      s.created_at = DateTime.parse submission["created"]

      s.add_file({
        url: submission["images"]["original"],
        created_at: s.created_at,
        identifier: "",
      })
      s
    end

    def fetch_api_identifier
      make_request("/character/#{url_identifier}")["id"]
    end

    private

    def make_request(endpoint, query = {})
      fetch_json("#{API_PREFIX}#{endpoint}", **{
        query: query,
        headers: {
          Authorization: "Bearer #{bearer_token}",
        },
      })
    end

    # This whole thing is very brittle and may break at any moment
    def bearer_token
      Cache.fetch("furrynetwork-token", 55.minutes) do
        SeleniumWrapper.driver do |driver|
          driver.navigate.to "https://furrynetwork.com/login"
          driver.manage.window.maximize
          driver.find_element(id: "email").send_keys Config.furrynetwork_user
          driver.find_element(id: "password").send_keys Config.furrynetwork_pass
          driver.find_element(css: ".page--login__form button[type='submit']").click
          driver.wait_for_element(class: "profile-switcher-menu")
          driver.execute_script "return JSON.parse(window.localStorage.getItem('token')).access_token"
        end
      end
    end
  end
end
