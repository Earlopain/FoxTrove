require "test_helper"

class IconGeneratorTest < ActiveSupport::TestCase
  test "the target file is up to date" do
    target_file = Tempfile.new
    stub_const(IconGenerator, :TARGET_FILE, target_file.path) do
      IconGenerator.run
    end
    assert(FileUtils.compare_file(target_file, IconGenerator::TARGET_FILE))
  end

  test "all files are named correctly" do
    ArtistUrl.site_types.each do |key, index|
      file_name = "#{index}-#{key}.png"
      assert_path_exists(IconGenerator::ICON_FOLDER.join(file_name))
    end
  end
end
