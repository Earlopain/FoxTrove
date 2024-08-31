require "test_helper"

class SeleniumWrapperTest < ActiveSupport::TestCase
  test "active" do
    Selenium::WebDriver.stubs(:for)

    assert_not_predicate(SeleniumWrapper, :active?)
    SeleniumWrapper.driver do
      assert_not_predicate(SeleniumWrapper, :active?)
      travel(10.seconds) do
        assert_predicate(SeleniumWrapper, :active?)
      end
    end
    assert_not_predicate(SeleniumWrapper, :active?)
  end
end
