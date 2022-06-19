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
