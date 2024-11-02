require "test_helper"

class EsbuildManifestTest < ActiveSupport::TestCase
  test "it correctly parses the entrypoints" do
    manifest = <<~JSON
      {
        "outputs": {
          "public/build/application-QTMXSKWO.js": {
            "entryPoint": "app/typescript/application.ts",
            "cssBundle": "public/build/application-D737BFOQ.css"
          },
          "public/build/application-D737BFOQ.css": {}
        }
      }
    JSON
    expected = {
      "application.ts" => "build/application-QTMXSKWO.js",
      "application.css" => "build/application-D737BFOQ.css",
    }
    stub_const(EsbuildManifest, :FILE_PATH, StringIO.new(manifest)) do
      assert_equal(expected, EsbuildManifest.parse)
    end
  end
end
