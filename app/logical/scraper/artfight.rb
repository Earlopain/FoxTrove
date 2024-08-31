module Scraper
  class Artfight < BufferedScraper
    STATE = :page

    def initialize(artist_url)
      super
      @page = 1
    end

    def fetch_next_batch
      single_attack_id = fetch_from_batch { get_attacks(@page) }
      return [] if single_attack_id.nil?

      [get_attack_details(single_attack_id)]
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

    def fetch_api_identifier
      html = fetch_html("https://artfight.net/~#{url_identifier}", headers: headers)
      html.at(".btn.btn-danger.report-button")&.attribute("data-id")&.value
    end

    private

    def get_attacks(page)
      html = fetch_html("https://artfight.net/~#{url_identifier}/attacks?page=#{page}", headers: headers)
      attacks = html.css(".profile-attacks-body a").select
      attacks.pluck("data-id")
    end

    def get_attack_details(id)
      html = fetch_html("https://artfight.net/attack/#{id}", headers: headers)
      date = html.at_css('.profile-header-normal-status div:contains("On:")').text
      {
        identifier: id,
        title: html.at_css(".h2.profile-header-name u").text,
        description: html.at_css("#attack-content .clearfix").text,
        created_at: DateTime.parse(date.sub("On:", "").strip),
        url: html.at_css('#attack-content a:contains("Full view")')["href"],
      }
    end

    def headers
      { Cookie: "laravel_session=#{fetch_cookie}" }
    end

    def fetch_cookie
      SeleniumWrapper.driver do |driver|
        driver.navigate.to "https://artfight.net/login"

        driver.wait_for_element(css: "input[name='username']").send_keys Config.artfight_user
        driver.find_element(css: "input[name='password']").send_keys Config.artfight_pass
        driver.find_element(css: "input[name='remember']").click
        driver.find_element(css: "input[value='Sign in']").click

        driver.cookie_value("laravel_session")
      end
    end
    cache(:fetch_cookie, 55.minutes)
  end
end
