# frozen_string_literal: true

SimpleCov.start "rails" do
  enable_coverage :branch

  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end

  groups.delete "Channels"
  groups.delete "Mailers"
  groups.delete "Libraries"

  add_group "Sites", "app/logical/sites"
  add_group "Scraper", "app/logical/scraper"
  add_group "Logical files" do |src_file|
    not_filtered_further = ["logical/sites", "logical/scraper"].none? { |e| src_file.filename.include? e }
    not_filtered_further && src_file.filename.include?("app/logical")
  end
end
