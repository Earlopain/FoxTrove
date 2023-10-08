# frozen_string_literal: true

require "test_helper"

class IconGeneratorTest < ActiveSupport::TestCase
  test "the target file is up to date" do
    target_file = Tempfile.new
    stub_const(IconGenerator, :TARGET_FILE, target_file.path) do
      IconGenerator.run
    end
    assert(FileUtils.compare_file(target_file, IconGenerator::TARGET_FILE))
  end
end
