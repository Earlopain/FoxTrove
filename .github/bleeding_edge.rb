lines = ["source \"https://rubygems.org\""]

Gem::Specification.stubs.each do |stub|
  url = stub.metadata["source_code_uri"] || stub.homepage
  matched = url[%r{https?://git(?:hub|lab)\.com/[^\/]*/[^\/]*}]
  if matched && stub.name != "minitest" && stub.name != "i18n" && stub.name != "logger"
    lines << "gem #{stub.name.inspect}, git: #{matched.inspect}"
  else
    lines << "gem #{stub.name.inspect}"
  end
end

File.write("Gemfile", lines.join("\n"))
