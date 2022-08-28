# frozen_string_literal: true

module Scraper
  # https://www.tumblr.com/docs/en/api/v2
  # This doesn't download the images, they just get reblogged
  # You can then export your data and import the archive instead
  class Tumblr < Base
    def init
      @offset = 0
    end

    def self.enabled?
      Config.tumblr_consumer_key.present? && Config.tumblr_consumer_secret.present? &&
        Config.tumblr_oauth_token.present? && Config.tumblr_oauth_secret.present? &&
        Config.tumblr_reblog_blog_uuid.present?
    end

    def fetch_next_batch
      response = get("https://api.tumblr.com/v2/blog/#{api_identifier}/posts/photo", {
        limit: 20,
        offset: @offset,
        npf: true,
        reblog_info: true,
      })
      @offset += 20
      posts = response["response"]["posts"]
      end_reached if posts.empty?
      posts.reject { |p| p["reblogged_from_id"] }
    end

    def to_submission(api_post)
      s = Submission.new
      s.identifier = api_post["id_string"]
      s.title = ""
      s.description = api_post["summary"]
      s.created_at = DateTime.strptime(api_post["timestamp"].to_s, "%s")
      # Prevent double reblogs, or when the scrape failed midway through
      if ArtistSubmission.for_site_with_identifier(identifier: api_post["id_string"], site: "tumblr").blank?
        response = reblog(api_post)
        raise StandardError, "Failed to reblog #{api_post['id_string']}: #{response.code}" if response.code != 201
      end
      s
    end

    def fetch_api_identifier
      response = get("https://api.tumblr.com/v2/blog/#{url_identifier}/info")["response"]
      return if response.is_a?(Array)

      response.dig("blog", "uuid")
    end

    private

    def get(url, query_params = {})
      fetch_json(url, **{
        query: query_params,
        headers: {
          Authorization: authorization_header(url, "get", query_params),
        },
      })
    end

    def post(url, params)
      fetch_json(url, :post, **{
        body: URI.encode_www_form(params),
        headers: {
          "Authorization": authorization_header(url, "post", params),
          "Content-Type": "application/x-www-form-urlencoded",
        },
      })
    end

    def reblog(api_post)
      post("https://api.tumblr.com/v2/blog/#{Config.tumblr_reblog_blog_uuid}/posts", {
        state: "draft",
        parent_tumblelog_uuid: api_identifier,
        parent_post_id: api_post["id_string"],
        reblog_key: api_post["reblog_key"],
      })
    end

    def authorization_header(url, method, params)
      nonce = SecureRandom.hex(16)
      timestamp = Time.current.to_i
      oauth_params = {
        oauth_consumer_key: Config.tumblr_consumer_key,
        oauth_nonce: nonce,
        oauth_signature_method: "HMAC-SHA1",
        oauth_timestamp: timestamp,
        oauth_token: Config.tumblr_oauth_token,
        oauth_version: "1.0",
      }
      signature_params = {
        **params,
        **oauth_params,
      }
      params_escaped = signature_params.sort.collect { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
      base_string = "#{method.upcase}&#{CGI.escape(url)}&#{CGI.escape(params_escaped)}"
      signing_key = "#{Config.tumblr_consumer_secret}&#{Config.tumblr_oauth_secret}"
      oauth_signature = Base64.encode64(OpenSSL::HMAC.digest("sha1", signing_key, base_string).to_s).chop
      "OAuth #{{ **oauth_params, oauth_signature: oauth_signature }.map { |k, v| "#{k}=\"#{CGI.escape(v.to_s)}\"" }.join(', ')}"
    end
  end
end
