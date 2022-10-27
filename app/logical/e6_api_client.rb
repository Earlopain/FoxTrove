# frozen_string_literal: true

module E6ApiClient
  module_function

  def iqdb_query(file)
    # FIXME: Proper rate limiting
    sleep 2
    make_request(:post, "/iqdb_queries.json", body: { file: file })
  end

  def get_posts_by_id(id_list)
    id_list = Array.wrap(id_list)
    raise StandardError, "You can only pass 100 ids at once" if id_list.size > 100

    make_request(:get, "/posts.json?tags=status:any id:#{id_list.join(',')}")["posts"]
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
