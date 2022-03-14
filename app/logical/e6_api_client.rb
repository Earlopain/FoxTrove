class E6ApiClient
  API_BASE = "https://e621.net".freeze

  def self.iqdb_enabled?
    Config.e6_user.present? && Config.e6_apikey.present?
  end

  def self.iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2
    HTTParty.post(
      "#{API_BASE}/iqdb_queries.json",
      body: { file: file },
      headers: {
        "Authorization": "Basic #{credentials}",
        "User-Agent": "reverser/0.1 (by earlopain)",
      }
    )
  end

  def self.credentials
    Base64.encode64("#{Config.e6_user}:#{Config.e6_apikey}")
  end
end
