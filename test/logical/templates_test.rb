# frozen_string_literal: true

require "test_helper"

class TemplatesTest < ActiveSupport::TestCase
  VIEW_PATH = Rails.root.join("app/views")

  test "all view partials declare the locals they accept" do
    VIEW_PATH.glob("**/_*.html.erb").each do |partial|
      line = File.open(partial, &:readline)
      message = <<~MSG.squish
        Expected #{partial.relative_path_from(Rails.root)} to declare strict locals.
        Use <%# locals: () -%> if the template accepts no locals
      MSG
      assert_match(/<%# locals:.* -%>/, line, message)
    end
  end

  test "all views declare a title" do
    partials = VIEW_PATH.glob("**/_*.html.erb")
    layouts = VIEW_PATH.glob("**/layouts/*.html.erb")
    (VIEW_PATH.glob("**/*.html.erb") - partials - layouts).each do |template|
      message = "Expected #{template.relative_path_from(Rails.root)} to declare a page title"
      assert_match(/<% page_title .* %>/, File.read(template), message)
    end
  end
end
