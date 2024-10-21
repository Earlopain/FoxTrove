lines = ["source \"https://rubygems.org\""]

Gem::Specification.stubs.each do |stub|
  url = stub.metadata["source_code_uri"] || stub.homepage
  matched = url[%r{https?://git(?:hub|lab)\.com/[^\/]*/[^\/]*}]
  if matched && stub.name != "minitest" && stub.name != "i18n" && stub.name != "logger" && stub.name != "parser" && stub.name != "regexp_parser" && stub.name != "rubocop-ast" && stub.name != "simplecov"
    lines << "gem #{stub.name.inspect}, git: #{matched.inspect}, submodules: true"
  else
    lines << "gem #{stub.name.inspect}"
  end
end

File.write("Gemfile", lines.join("\n"))
