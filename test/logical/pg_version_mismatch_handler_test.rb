# frozen_string_literal: true

require "test_helper"

class PgVersionMismatchHandlerTest < ActionDispatch::IntegrationTest
  def stub_version(version)
    DockerEnv.stubs(:pg_data_version).returns(version)
    @app = PgVersionMismatchHandler.new(->(_env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] })
  end

  def test_version_same
    stub_version(DockerEnv::NEEDED_PG_VERSION)
    get "/"
    assert_equal("OK", @response.body)
  end

  def test_version_different
    stub_version("#{DockerEnv::NEEDED_PG_VERSION}FOO")
    get "/"
    assert_match(/Version Mismatch/, @response.body)
  end
end
