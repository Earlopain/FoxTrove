require "test_helper"

class E6ApiClientTest < ActiveSupport::TestCase
  test "get_post" do
    stub_request_once(:get, "#{E6ApiClient::ORIGIN}/posts/1.json", body: { post: { id: 1 } }.to_json, headers: { content_type: "application/json" })
    assert_equal(1, E6ApiClient.get_post(1)["id"])
  end
end
