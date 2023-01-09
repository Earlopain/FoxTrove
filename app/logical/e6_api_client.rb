# frozen_string_literal: true

module E6ApiClient
  module_function

  def iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2
    make_request(:post, "/iqdb_queries.json", body: { file: file })
  end

  def get_post(id)
    make_request(:get, "/posts/#{id}.json")["post"]
  end

  def get_posts(ids)
    make_request(:get, "/posts.json?limit=300&tags=status:any id:#{ids.join(',')}")["posts"]
  end

  def make_request(method, path, **params)
    params[:headers] ||= {}
    params[:headers].merge!(headers)
    HTTParty.send(method, "https://e621.net#{path}", params)
  end

  def headers
    {
      "Authorization": "Basic #{credentials(Config.e6_user, Config.e6_apikey)}",
      "User-Agent": "reverser/0.1 (by earlopain)",
    }
  end

  def credentials(username, api_key)
    Base64.encode64("#{username}:#{api_key}")
  end
end
