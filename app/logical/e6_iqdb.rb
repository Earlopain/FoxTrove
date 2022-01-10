module E6Iqdb
  URL = "https://e621.net/iqdb_queries.json".freeze

  def self.query(file)
    # FIXME: Proper rate limiting
    sleep 2
    HTTParty.post(
      URL,
      body: { file: file },
      headers: {
        "Authorization": "Basic #{credentials}",
        "User-Agent": "#{Config.e6_user} gallery reverse",
      }
    )
  end

  def self.credentials
    Base64.encode64("#{Config.e6_user}:#{Config.e6_apikey}")
  end
end
