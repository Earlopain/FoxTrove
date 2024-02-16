# frozen_string_literal: true

require "test_helper"

class StrictLocalsTest < ActiveSupport::TestCase
  test "all view partials declare the locals they accept" do
    Rails.root.join("app/views").glob("**/_*.html.erb").each do |partial|
      line = File.open(partial, &:readline)
      message = <<~MSG.squish
        Expected #{partial.relative_path_from(Rails.root)} to declare strict locals.
        Use <%# locals: () -%> if the template accepts no locals
      MSG
      assert_match(/<%# locals:.* -%>/, line, message)
    end
  end
end
