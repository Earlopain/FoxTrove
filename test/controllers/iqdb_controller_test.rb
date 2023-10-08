# frozen_string_literal: true

require "test_helper"

class IqdbControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get iqdb_path
    assert_response :success
  end

  test "search by url returns results" do
    files = create_list(:submission_file_for_view, 3, file_name: "1.webp")
    response = [
      {
        post_id: files[0].id,
        score: 70,
      },
      {
        post_id: files[2].id,
        score: 80,
      },
    ]

    stub_request(:get, "https://example.com/").to_return(body: file_fixture("1.jpg").open)
    stub_request(:post, "http://iqdb:5588/query").to_return(body: response.to_json, headers: { content_type: "application/json" })
    post search_iqdb_path, params: { search: { url: "https://example.com" } }

    assert_response :success
    assert_dom ".submission-sample", 2
    assert_dom ".submission-sample[data-id=#{files[0].id}]", 1
    assert_dom ".submission-sample[data-id=#{files[2].id}]", 1
  end
end
