require "test_helper"

class ArchiveImportsControllerTest < ActionDispatch::IntegrationTest
  test "new renders" do
    get new_archive_import_path
    assert_response :success
  end
end
