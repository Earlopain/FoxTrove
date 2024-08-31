require "test_helper"

class IqdbControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get iqdb_path
    assert_response :success
  end

  test "search by url returns results" do
    files = create_list(:submission_file_with_original, 3, file_name: "1.webp")

    stub_request(:get, "https://example.com/").to_return(body: file_fixture("1.jpg").open)
    stub_iqdb(files[0] => 70, files[2] => 80) do
      post search_iqdb_path, params: { search: { url: "https://example.com" } }
    end

    assert_response :success
    assert_dom ".submission-sample", 2
    assert_dom ".submission-sample[data-id=#{files[0].id}]", 1
    assert_dom ".submission-sample[data-id=#{files[2].id}]", 1
  end

  test "search by e6 url" do
    sm = create(:submission_file_with_original, file_name: "1.webp")
    e6_post = build(:e6_post_response, post_id: 123, md5: "abcdefg")
    stub_request_once(:get, e6_post[:post][:sample][:url], body: file_fixture("1.webp").read)
    stub_e6_post(e6_post) do
      stub_iqdb(sm => 80) do
        post search_iqdb_path, params: { search: { url: "https://e621.net/posts/123" } }
      end
    end

    assert_response :success
    assert_dom ".submission-sample", 1
  end

  test "search by file" do
    sm = create(:submission_file_with_original, file_name: "1.webp")
    stub_iqdb(sm => 80) do
      post search_iqdb_path, params: { search: { file: file_fixture_upload("1.webp") } }
    end

    assert_response :success
    assert_dom ".submission-sample", 1
  end

  test "search without parameters" do
    post search_iqdb_path

    assert_response :success
    assert_dom ".submission-sample", 0
  end
end
