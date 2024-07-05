# frozen_string_literal: true

require "test_helper"

class IqdbControllerTest < ActionDispatch::IntegrationTest
  test "new renders" do
    get new_archive_import_path
    assert_response :success
  end
end
