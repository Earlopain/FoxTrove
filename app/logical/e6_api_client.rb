module E6ApiClient
  ORIGIN = "https://e621.net"
  extend self

  def iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2 unless Rails.env.test?
    client.post("/iqdb_queries.json", form: { file: file }).raise_for_status.json
  end

  def get_post(id)
    client.get("/posts/#{id}.json").raise_for_status.json["post"]
  end

  private

  def client
    @client ||= HTTPX
      .plugin(:basic_auth)
      .basic_auth(Config.e6_user, Config.e6_apikey)
      .with(origin: ORIGIN, headers: { "user-agent" => Scraper::Base::FRIENDLY_USER_AGENT })
  end
end
