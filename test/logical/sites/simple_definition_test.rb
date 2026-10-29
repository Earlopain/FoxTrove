require "test_helper"

module Sites
  class SimpleDefinitionTest < ActiveSupport::TestCase
    def new_definition(gallery_templates: [], submission_template: "")
      definition = {
        type: "SimpleDefinition",
        enum_value: "dummy",
        display_name: "Dummy",
        homepage: "https://example.com",
        gallery_templates: gallery_templates,
        username_identifier_regex: "[a-zA-Z0-9_@.+-]*",
        api_identifier_regex: "[a-zA-Z0-9_@.+-]*",
        submission_template: submission_template,
      }.stringify_keys
      Sites::SimpleDefinition.new(definition)
    end

    setup do
      @artist_url = create(:artist_url, url_identifier: "foo", api_identifier: "bar")
    end

    test "#gallery_url with url identifier only" do
      definition = new_definition(gallery_templates: ["example.com/{site_artist_identifier}"])
      assert_equal("https://example.com/foo", definition.gallery_url(@artist_url))
    end

    test "#gallery_url with api identifier only" do
      definition = new_definition(gallery_templates: ["example.com/{site_artist_api_identifier}"])
      assert_equal("https://example.com/bar", definition.gallery_url(@artist_url))
    end
  end
end
