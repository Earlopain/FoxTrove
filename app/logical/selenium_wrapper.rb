class SeleniumWrapper
  def self.driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_option("excludeSwitches", ["enable-automation"])
    options.add_option("useAutomationExtension", false)

    cps = Selenium::WebDriver::Remote::Capabilities.chrome "goog:loggingPrefs": {}

    driver = Selenium::WebDriver.for :remote, capabilities: [options, cps], url: "http://selenium:4444"
    yield driver
  ensure
    driver.quit
  end
end
