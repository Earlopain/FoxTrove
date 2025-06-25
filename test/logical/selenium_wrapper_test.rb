require "test_helper"

class SeleniumWrapperTest < ActiveSupport::TestCase
  test "active" do
    assert_not_predicate(SeleniumWrapper, :active?)

    Selenium::WebDriver.stub(:for, nil) do
      SeleniumWrapper.driver do
        assert_not_predicate(SeleniumWrapper, :active?)
        travel(10.seconds) do
          assert_predicate(SeleniumWrapper, :active?)
        end
      end
    end

    assert_not_predicate(SeleniumWrapper, :active?)
  end
end
