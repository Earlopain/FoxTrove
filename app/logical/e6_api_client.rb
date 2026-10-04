module E6ApiClient
  ORIGIN = "https://e621.net"
  extend self

  def iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2 unless Rails.env.test?
    iqdb_response = client.post("/iqdb_queries.json?v2=true", form: { file: file }).raise_for_status.json

    if (ids = iqdb_response.pluck("post_id")).any?
      post_json = E6ApiClient.get_posts(ids).index_by { it["id"] }
      iqdb_response.each do |entry|
        entry["post"] = post_json[entry["post_id"]]
      end
    end
    iqdb_response
  end

  def get_post(id)
    client.get("/posts/#{id}.json?v2=true&mode=extended").raise_for_status.json
  end

  def get_posts(ids)
    client.get("/posts.json", params: { v2: true, mode: :extended, limit: 300, tags: "status:any id:#{ids.join(',')}" }).raise_for_status.json
  end

  private

  def client
    @client ||= HTTPX
      .plugin(:basic_auth)
      .basic_auth(Config.e6_user, Config.e6_apikey)
      .with(origin: ORIGIN, headers: { "user-agent" => Scraper::Base::FRIENDLY_USER_AGENT })
  end
end
