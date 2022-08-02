# frozen_string_literal: true

class E6ApiClient
  API_BASE = "https://e621.net"

  def self.enabled?
    Config.e6_user.present? && Config.e6_apikey.present?
  end

  def self.iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2
    HTTParty.post(
      "#{API_BASE}/iqdb_queries.json",
      body: { file: file },
      headers: headers,
    )
  end

  def self.headers
    raise StandardError, "E6 login credentials are not set" unless enabled?

    {
      "Authorization": "Basic #{credentials(Config.e6_user, Config.e6_apikey)}",
      "User-Agent": "reverser/0.1 (by earlopain)",
    }
  end

  def self.credentials(username, api_key)
    Base64.encode64("#{username}:#{api_key}")
  end
end
