module Scraper
  # https://deviantart.readme.io/docs/getting-started
  class Deviantart < Base
    STATE = "next_offset"
    API_PREFIX = "https://www.deviantart.com/api/v1/oauth2"

    def initialize(artist_url)
      super
      @next_offset = nil
    end

    # https://deviantart.readme.io/reference/gallery_all
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

    # https://deviantart.readme.io/reference/deviation_download
    def get_download_link(data)
      make_api_call("/deviation/download/#{data[0]}")["src"]
    end

    # https://deviantart.readme.io/reference/user_profile
    def fetch_api_identifier
      json = make_api_call("/user/profile/#{url_identifier}")
      return nil if json["error_code"] == 2

      json.dig("user", "userid")
    end

    private

    def make_api_call(endpoint, params = {})
      fetch_json("#{API_PREFIX}#{endpoint}",
        params: params,
        headers: {
          "dA-minor-version": "20210526",
          "Authorization": "Bearer #{access_token}",
        },
      )
    end

    # https://deviantart.readme.io/docs/authentication
    def access_token
      redirect_uri = "https://localhost"
      code_verifier = SecureRandom.base36(46)

      code = SeleniumWrapper.driver do |driver|
        authorize_params = {
          response_type: "code",
          client_id: Config.deviantart_client_id_v2,
          redirect_uri: redirect_uri,
          scope: "browse",
          code_challenge: Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier), padding: false),
          code_challenge_method: "S256",
        }
        driver.navigate.to "https://www.deviantart.com/oauth2/authorize?#{authorize_params.to_query}"

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
        client_id: Config.deviantart_client_id_v2,
        client_secret: Config.deviantart_client_secret_v2,
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri,
        code_verifier: code_verifier,
      })
      response["access_token"]
    end
    cache(:access_token, 55.minutes)
  end
end
