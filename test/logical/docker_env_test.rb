require "test_helper"

class DockerEnvTest < ActiveSupport::TestCase
  def test_expected_postgres_version_is_correct
    data = Psych.safe_load_file(Rails.root.join("docker-compose.yml"), aliases: true)
    image_name = data.dig("services", "postgres", "image")
    version = image_name[/:(.*)-/, 1].to_i.to_s
    assert_equal(DockerEnv::NEEDED_PG_VERSION, version)
  end
end
