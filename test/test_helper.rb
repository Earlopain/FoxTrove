ENV["RAILS_ENV"] ||= "test"
ENV["MT_NO_EXPECTATIONS"] ||= "1"

require "simplecov"
SimpleCov::SourceFile.prepend(Module.new do
  def coverage_exceeding_source_warn
    # no-op, https://github.com/simplecov-ruby/simplecov/issues/1057
  end
end)

SimpleCov.start "rails" do
  enable_coverage :branch
  enable_coverage_for_eval
  track_files "{app,lib}/**/*.{rb,erb}"

  groups.delete "Channels"
  groups.delete "Mailers"
  groups.delete "Libraries"

  add_group "Sites", "app/logical/sites"
  add_group "Scraper", "app/logical/scraper"
  add_group "Views", "app/views"
  add_group "Logical" do |src_file|
    not_filtered_further = ["logical/sites", "logical/scraper"].none? { |e| src_file.filename.include? e }
    not_filtered_further && src_file.filename.include?("app/logical")
  end
end

if ENV["CI"]
  require "simplecov_json_formatter"
  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
end

require_relative "../config/environment"
require "rails/test_help"
require "minitest-spec-rails"

require "factory_bot"
require "minitest/mock"
require "mocha/minitest"
require "webmock/minitest"
require "httpx/adapters/webmock"

FactoryBot.find_definitions
FactoryBot::SyntaxRunner.class_eval do
  include ActiveSupport::Testing::FileFixtures
  self.file_fixture_path = ActiveSupport::TestCase.file_fixture_path
end

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    setup do
      WebMock.enable!
      WebMock.disable_net_connect!
      Rails.cache.clear
    end

    def stub_config(**params, &)
      params.each do |key, value|
        Config.define_singleton_method(key) { value }
      end
      yield
    ensure
      params.each_key do |key|
        Config.remove_possible_singleton_method(key)
      end
    end

    def stub_e6_iqdb(response, &)
      stub = stub_request_once(:post, "https://e621.net/iqdb_queries.json", body: response.to_json, headers: { content_type: "application/json" })
      stub_for_block(stub, &)
    end

    def stub_e6_post(response, &)
      id = response[:post][:id]
      stub = stub_request_once(:get, "https://e621.net/posts/#{id}.json", body: response.to_json, headers: { content_type: "application/json" })
      stub_for_block(stub, &)
    end

    def stub_iqdb(result, &)
      response = result.map { |sm, score| { post_id: sm.id, score: score } }.to_json
      stub = stub_request_once(:post, "#{DockerEnv.iqdb_url}/query", body: response, headers: { content_type: "application/json" })
      stub_for_block(stub, &)
    end

    def stub_scraper_enabled(*site_types, &)
      sites = site_types.map { |site_type| Sites.from_enum(site_type.to_s) }
      block = proc(&)
      sites.each.with_index do |site, index|
        raise ArgumentError, "#{site_types[index]} is not a valid scraper" unless site.scraper?

        prev_block = block
        block = proc { site.stub(:scraper_enabled?, true, &prev_block) }
      end
      block.call
    end

    def stub_request_once(method, url_matcher, **)
      stub_request(method, url_matcher).to_return(**)
        .then.to_raise(ArgumentError.new("can only be stubbed once"))
    end

    private

    def stub_for_block(stub)
      yield
    ensure
      remove_request_stub(stub)
    end
  end
end
