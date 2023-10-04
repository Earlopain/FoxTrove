# frozen_string_literal: true

module DockerEnv
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
end
