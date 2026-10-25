require "test_helper"

class ScraperLogsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    create(:scraper_log, request: {
      method: "get",
      path: "foo.com",
      request_params: { params: { foo: "bar" } },
    })
    create(:scraper_log, request: {
      method: "get",
      path: "foo.com",
      request_params: { body: "Hello World!" },
    })
    create(:scraper_log, request: {
      method: "get",
      path: "foo.com",
      request_params: { json: { foo: "bar" } },
    })
    create(:scraper_log, request: { method: "get", path: "foo.com" })
    get scraper_logs_path
    assert_response :success
  end

  test "show for json response" do
    scraper_log = create(:scraper_log, request: {
      method: "get",
      path: "foo.com",
      response_body: "{}",
    })
    get scraper_log_path(scraper_log)
    assert_response :success
  end

  test "show for non-json response" do
    scraper_log = create(:scraper_log, request: {
      method: "get",
      path: "foo.com",
      response_body: "Hi!",
    })
    get scraper_log_path(scraper_log)
    assert_response :success
  end
end
