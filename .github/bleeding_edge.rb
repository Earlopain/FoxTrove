require "bundler"

remote = "https://rubygems.org"
fetcher = Bundler::Fetcher.new(Bundler::Source::Rubygems::Remote.new(remote))
dsl = Bundler::Dsl.evaluate("#{__dir__}/../Gemfile", "#{__dir__}/../Gemfile.lock", {})
stubs = dsl.resolve.materialize(dsl.dependencies_for(%w[default test])).map do |stub|
  Bundler::RemoteSpecification.new(stub.name, stub.version, stub.platform, fetcher)
end

lines = ["source #{remote.inspect}"]
NO_GIT = [
  "minitest", # https://github.com/minitest/minitest/issues/750 (lol)
].freeze
FULL_SKIP = [
  "simplecov-html", # https://github.com/simplecov-ruby/simplecov-html/pull/145
  "nokogiri", # Unknown, mini_portile2 is not found during the build. Maybe platform-related.
  "mini_portile2",
].freeze

stubs.each do |stub|
  url = stub.metadata["source_code_uri"] || stub.homepage
  matched = url[%r{https?://git(?:hub|lab)\.com/[^\/]*/[^\/]*}]
  next if FULL_SKIP.include?(stub.name)

  lines << if matched && !NO_GIT.include?(stub.name) # rubocop:disable Rails/NegateInclude
             "gem #{stub.name.inspect}, git: #{matched.inspect}, submodules: true"
           else
             "gem #{stub.name.inspect}"
           end
end

File.write("Gemfile", lines.join("\n"))
