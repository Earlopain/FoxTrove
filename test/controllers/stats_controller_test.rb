require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    get stats_path
    assert_response :success
  end

  test "selenium active" do
    get selenium_stats_path
    assert_response :success
    assert_not(@response.parsed_body[:active])
  end
end
