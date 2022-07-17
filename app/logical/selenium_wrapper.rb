# frozen_string_literal: true

class SeleniumWrapper
  def self.driver(with_performance: false)
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_option("excludeSwitches", ["enable-automation"])
    options.add_option("useAutomationExtension", false)

    prefs = {}
    prefs[:performance] = "ALL" if with_performance
    cps = Selenium::WebDriver::Remote::Capabilities.chrome "goog:loggingPrefs": prefs

    driver = Selenium::WebDriver.for :remote, capabilities: [options, cps], url: Config.selenium_url
    yield driver
  ensure
    driver&.quit
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
      end
    end
  end
end
