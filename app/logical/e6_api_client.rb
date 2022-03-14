class E6ApiClient
  API_BASE = "https://e621.net".freeze

  def initialize(username = nil, api_key = nil)
    @username = username
    @api_key = api_key
  end

  def user_by_name(username)
    make_request("users/#{username}.json")
  end

  def make_request(path, query = {})
    response = HTTParty.get(
      "#{API_BASE}/#{path}",
      query: query,
      headers: self.class.headers(@username, @api_key)
    )
    JSON.parse response.body
  end

  def self.iqdb_enabled?
    Config.e6_user.present? && Config.e6_apikey.present?
  end

  def self.iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2
    HTTParty.post(
      "#{API_BASE}/iqdb_queries.json",
      body: { file: file },
      headers: headers(Config.e6_user, Config.e6_apikey)
    )
  end

  def self.headers(username, api_key)
    {}.tap do |h|
      h["Authorization"] = "Basic #{credentials(username, api_key)}" if username.present? && api_key.present?
      h["User-Agent"] = "reverser/0.1 (by earlopain)"
    end
  end

  def self.credentials(username, api_key)
    Base64.encode64("#{username}:#{api_key}")
  end
end
