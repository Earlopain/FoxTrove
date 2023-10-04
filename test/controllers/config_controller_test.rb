# frozen_string_literal: true

require "test_helper"

class ConfigControllerTest < ActionDispatch::IntegrationTest
  test "index renders" do
    get config_index_path
    assert_response :success
  end

  test "show renders" do
    get config_path("twitter")
    assert_response :success
  end
end
