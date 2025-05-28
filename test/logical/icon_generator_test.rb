require "test_helper"

class IconGeneratorTest < ActiveSupport::TestCase
  test "the target file is up to date" do
    Tempfile.create do |target_file|
      stub_const(IconGenerator, :TARGET_FILE, target_file.path) do
        IconGenerator.run
      end

      expected = Vips::Image.new_from_file(IconGenerator::TARGET_FILE.to_path).to_a
      actual = Vips::Image.new_from_file(target_file.path).to_a
      equal = expected == actual # No assert_equal to supress printing a huge array diff on failure
      assert(equal, "Outdated icons, regenerate with `bin/rails r IconGenerator.run`")
    end
  end

  test "the target file has correct dimensions" do
    icons = Vips::Image.new_from_file(IconGenerator::TARGET_FILE.to_path)
    assert_equal(IconGenerator::ICON_SIZE, icons.width)
    assert_equal(IconGenerator::ICON_SIZE * ArtistUrl.site_types.count, icons.height)
  end

  test "all files are named correctly" do
    ArtistUrl.site_types.each do |key, index|
      file_name = "#{index}-#{key}.png"
      assert_path_exists(IconGenerator::ICON_FOLDER.join(file_name))
    end
  end
end
