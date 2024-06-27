# frozen_string_literal: true

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
end
