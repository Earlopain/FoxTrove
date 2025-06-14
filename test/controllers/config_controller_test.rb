require "test_helper"

class ConfigControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    get config_index_path
    assert_response :success
  end

  Sites.scraper_definitions.each do |definition|
    test "show #{definition.site_type} renders" do
      get config_path(definition.site_type)
      assert_response :success
    end
  end

  test "show for a non-existing site" do
    get config_path("foo")
    assert_response :not_found
  end

  test "show includes setup instructions when available" do
    get config_path("furaffinity")
    assert_response :success
    assert_select "#setup-instructions"

    get config_path("twitter")
    assert_response :success
    assert_select "#setup-instructions", count: 0
  end

  test "modify" do
    Tempfile.create do |f|
      Config.unstub(:custom_config)
      stub_const(Config, :CUSTOM_PATH, Pathname.new(f.path)) do
        put modify_config_index_path, params: { config: {
          files_per_page: "75",
          furaffinity_user: "foo",
          log_scraper_requests: "false",
        } }

        assert_redirected_to(config_index_path)
        assert_equal(75, Config.files_per_page)
        assert_equal("foo", Config.furaffinity_user)
        assert_not_predicate(Config, :log_scraper_requests?)
      end
    end
  ensure
    Config.reset_cache
  end
end
