require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  class QueryParameterNormalizationTest < ActionDispatch::IntegrationTest
    test "blank parameters are removed" do
      get artists_path, params: { search: "", whatever: nil, foo: "bar" }
      assert_redirected_to artists_path(foo: "bar")
    end

    test "nested blank parameters are removed" do
      get artists_path, params: { search: { name: "bar", site_type: nil } }
      assert_redirected_to artists_path(search: { name: "bar" })
    end

    test "empty arrays are removed" do
      get artists_path, params: { search: { name: [], site_type: ["123"] } }
      assert_redirected_to artists_path(search: { site_type: ["123"] })
    end

    test "doesn't redirect if there are no blank parameters" do
      get artists_path, params: { foo: "bar" }
      assert_response :success
    end
  end

  test "not found error page" do
    get artist_path(id: -1)
    assert_response :not_found
    assert_match(/Not Found/, @response.body)
    assert_select(".error-backtrace", 0)
  end

  test "forbidden error page" do
    get artists_path(search: { foo: "bar" })
    assert_response :forbidden
    assert_select(".error-backtrace")
  end

  class PaginationTest < ActionDispatch::IntegrationTest
    def assert_active_links(*expected)
      actual = css_select(".paginator a").map { it.attribute("aria-disabled")&.value != "true" }
      assert_equal(expected, actual)
    end

    test "all links disabled when only one page" do
      create(:artist)
      get artists_path(page: 1, limit: 1)
      assert_response :success
      assert_active_links(false, false, false)
    end

    test "gap present when applicable" do
      create_list(:artist, 8)
      get artists_path(page: 1, limit: 1)
      assert_response :success
      assert_select ".paginator a.gap", count: 1
    end

    test "current page is disabled" do
      create_list(:artist, 3)
      get artists_path(page: 2, limit: 1)
      assert_response :success
      assert_active_links(true, true, false, true, true)
    end
  end
end
