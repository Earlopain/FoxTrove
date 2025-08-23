module Scraper
  # https://www.deviantart.com/developers/http/v1/20210526
  # https://www.deviantart.com/developers/console
  class Deviantart < Base
    STATE = "next_offset"
    API_PREFIX = "https://www.deviantart.com/api/v1/oauth2"

    def initialize(artist_url)
      super
      @next_offset = nil
    end

    # https://www.deviantart.com/developers/http/v1/20210526/gallery_all/bdb19761e6debcc6609356d6b78f4a5d
    def fetch_next_batch
      json = make_api_call("/gallery/all", {
        username: url_identifier,
        limit: 24,
        mature_content: true,
        offset: @next_offset,
      })
      end_reached unless json["has_more"]
      @next_offset = json["next_offset"]
      json["results"].reject { |r| r["content"].nil? }
    end

    def to_submission(submission)
      s = Submission.new
      # Extract number from https://www.deviantart.com/kenket/art/Rowdy-829623906
      s.identifier = submission["url"].match(/-([0-9]*)$/)[1]
      s.title = submission["title"]
      # FIXME: Title is only available when doing deviation/{deviationid}?expand=deviation.fulltext
      s.description = ""
      s.created_at = DateTime.strptime(submission["published_time"], "%s")
      s.add_file({}.tap do |hash|
        hash[:url_data] = [submission["deviationid"]] if submission["is_downloadable"]
        hash[:url] = submission["content"]["src"].gsub(/q_\d+(,strp)?/, "q_100") unless submission["is_downloadable"]
        hash[:created_at] = s.created_at
        hash[:identifier] = ""
      end)
      s
    end

    # https://www.deviantart.com/developers/http/v1/20210526/deviation_download/bed6982b88949bdb08b52cd6763fcafd
    def get_download_link(data)
      make_api_call("/deviation/download/#{data[0]}")["src"]
    end

    # https://www.deviantart.com/developers/http/v1/20210526/user_profile/0b06f6d6c8aa25b33b52f836e53f4f65
    def fetch_api_identifier
      json = make_api_call("/user/profile/#{url_identifier}")
      return nil if json["error_code"] == 2

      json.dig("user", "userid")
    end

    private

    def make_api_call(endpoint, params = {})
      fetch_json("#{API_PREFIX}#{endpoint}",
        params: {
          access_token: access_token,
          **params,
        },
        headers: {
          "dA-minor-version": "20210526",
        },
      )
    end

    # https://www.deviantart.com/developers/authentication
    def access_token
      redirect_uri = "http://localhost"
      code = SeleniumWrapper.driver do |driver|
        autorize_params = {
          response_type: "code",
          client_id: Config.deviantart_client_id,
          redirect_uri: redirect_uri,
          scope: "browse",
        }
        driver.navigate.to "https://www.deviantart.com/oauth2/authorize?#{autorize_params.to_query}"

        # Move from signup to login
        driver.wait_for_element(xpath: "//*[text()='Log In']").click

        driver.wait_for_element(id: "username").send_keys Config.deviantart_user
        driver.find_element(id: "loginbutton").click
        driver.wait_for_element(id: "password").send_keys Config.deviantart_pass
        driver.find_element(id: "loginbutton").click

        begin
          break driver.wait_for { Addressable::URI.parse(driver.current_url).query_values&.dig("code") }
        rescue Selenium::WebDriver::Error::TimeoutError
          # Not on the redirect page, authorize the application instead
        end

        # Authorize application
        driver.wait_for_element(css: "button[type='submit']").click

        driver.wait_for { Addressable::URI.parse(driver.current_url).query_values&.dig("code") }
      end
      response = fetch_json("https://www.deviantart.com/oauth2/token", params: {
        client_id: Config.deviantart_client_id,
        client_secret: Config.deviantart_client_secret,
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri,
      })
      response["access_token"]
    end
    cache(:access_token, 55.minutes)
  end
end
