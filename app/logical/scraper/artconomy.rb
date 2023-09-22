# frozen_string_literal: true

module Scraper
  class Artconomy < Base
    def initialize(artist_url)
      super
      @page = 1
    end

    def self.required_config_keys
      %i[artconomy_user artconomy_pass]
    end

    def self.state
      :page
    end

    def fetch_next_batch
      response = fetch_json("https://artconomy.com/api/profiles/v1/account/#{url_identifier}/submissions/art/?page=#{@page}", headers: headers)
      @page += 1
      end_reached if response["results"].size != 50
      response["results"]
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = submission["caption"]
      s.created_at = DateTime.parse submission["created_on"]

      s.add_file({
        url: submission["file"]["full"],
        created_at: s.created_at,
        identifier: submission["id"],
      })
      s
    end

    def fetch_api_identifier
      response = fetch_json("https://artconomy.com/api/profiles/v1/account/#{url_identifier}/")
      response["id"]
    end

    private

    def headers
      { Cookie: "sessionid=#{fetch_cookie}" }
    end

    def fetch_cookie
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://artconomy.com/auth/login"
        driver.wait_for_element(id: "field-login__email").send_keys Config.artconomy_user
        driver.find_element(id: "field-login__password").send_keys Config.artconomy_pass
        driver.find_element(id: "loginSubmit").click
        driver.wait_for_cookie("sessionid")
      end
    end
    cache(:fetch_cookie, 2.weeks)
  end
end
