module E6Iqdb
  URL = "https://e621.net/iqdb_queries.json".freeze

  def self.enabled?
    Config.e6_user.present? && Config.e6_apikey.present?
  end

  def self.query(file)
    # FIXME: Proper rate limiting
    sleep 2
    HTTParty.post(
      URL,
      body: { file: file },
      headers: {
        "Authorization": "Basic #{credentials}",
        "User-Agent": "reverser/0.1 (by earlopain) running through #{Config.e6_user}",
      }
    )
  end

  def self.credentials
    Base64.encode64("#{Config.e6_user}:#{Config.e6_apikey}")
  end
end
