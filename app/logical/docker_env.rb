module DockerEnv
  NEEDED_PG_VERSION = "17"

  module_function

  def exposed_vnc_port
    ENV.fetch("EXPOSED_VNC_PORT")
  end

  def iqdb_url
    ENV.fetch("IQDB_URL")
  end

  def selenium_url
    ENV.fetch("SELENIUM_URL")
  end

  def pg_data_version
    `sudo cat /docker/db_data/PG_VERSION`.strip.presence || NEEDED_PG_VERSION
  end

  def specifies_docker_user?
    ENV.key?("DOCKER_USER")
  end

  def specifies_deprecated_data_path?
    ENV.key?("REVERSER_DATA_PATH")
  end

  def master_commit
    @master_commit ||= begin
      File.read("/docker/git_master_ref").first(GitHelper::COMMIT_ABREV_LENGTH)
    rescue Errno::ENOENT
      # The .git folder doesn't exist during build on CI for some reason
      ""
    end
  end

  def docker_relevant_files
    %w[Dockerfile docker-compose.yml .dockerignore Gemfile Gemfile.lock]
  end
end
