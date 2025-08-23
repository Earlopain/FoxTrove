require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  describe "query parameter normalization" do
    def test_it_removes_blank_parameters
      get artists_path, params: { search: "", whatever: nil, foo: "bar" }
      assert_redirected_to artists_path(foo: "bar")
    end

    def test_it_removes_nested_blank_parameters
      get artists_path, params: { search: { name: "bar", site_type: nil } }
      assert_redirected_to artists_path(search: { name: "bar" })
    end

    def test_it_removes_empty_arrays
      get artists_path, params: { search: { name: [], site_type: ["123"] } }
      assert_redirected_to artists_path(search: { site_type: ["123"] })
    end

    def test_no_redirect_if_nothing_changed
      get artists_path, params: { foo: "bar" }
      assert_response :success
    end
  end

  describe "error page" do
    def test_not_found_page
      get artist_path(id: -1)
      assert_response :not_found
      assert_match(/Not Found/, @response.body)
      assert_select(".error-backtrace", 0)
    end

    def test_error_page
      get artists_path(search: { foo: "bar" })
      assert_response :forbidden
      assert_select(".error-backtrace")
    end
  end

  describe "paginator" do
    def assert_active_links(*expected)
      actual = css_select(".paginator a").map { it.attribute("aria-disabled")&.value != "true" }
      assert_equal(expected, actual)
    end

    def test_all_links_disabled_when_only_one_page
      create(:artist)
      get artists_path(page: 1, limit: 1)
      assert_response :success
      assert_active_links(false, false, false)
    end

    def test_has_gap_when_applicable
      create_list(:artist, 8)
      get artists_path(page: 1, limit: 1)
      assert_response :success
      assert_select ".paginator a.gap", count: 1
    end

    def test_current_page_is_disabled
      create_list(:artist, 3)
      get artists_path(page: 2, limit: 1)
      assert_response :success
      assert_active_links(true, true, false, true, true)
    end
  end
end
