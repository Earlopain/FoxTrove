# frozen_string_literal: true

class SeleniumWrapper
  def self.driver(with_performance: false)
    options = Selenium::WebDriver::Chrome::Options.new(exclude_switches: ["enable-automation"])
    options.add_argument("--disable-blink-features=AutomationControlled")

    prefs = {}
    prefs[:performance] = "ALL" if with_performance
    cps = Selenium::WebDriver::Options.chrome "goog:loggingPrefs": prefs

    driver = Selenium::WebDriver.for :remote, capabilities: [options, cps], url: Config.selenium_url
    if block_given?
      begin
        yield driver
      ensure
        driver&.quit
      end
    else
      driver
    end
  end
end

module Selenium
  module WebDriver
    module Remote
      class Driver
        def cookie_value(cookie_name)
          manage.cookie_named(cookie_name)[:value]
        rescue Selenium::WebDriver::Error::NoSuchCookieError
          nil
        end

        def wait_for(timeout: 10, &)
          wait = Selenium::WebDriver::Wait.new(timeout: timeout)
          wait.until(&)
        end

        def wait_for_cookie(cookie_name, timeout: 10)
          wait_for(timeout: timeout) { cookie_value(cookie_name) }
        end

        def wait_for_element(timeout: 10, **selector_params)
          wait_for(timeout: timeout) { find_element(**selector_params) }
        end
      end
    end
  end
end
