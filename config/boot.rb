ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

$VERBOSE = 1
def Warning.warn(msg, ...)
  return if msg.include?("rouge") # https://github.com/rouge-ruby/rouge/issues/1961

  raise StandardError, msg
end

require "bundler/setup" # Set up gems listed in the Gemfile.
