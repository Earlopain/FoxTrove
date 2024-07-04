# frozen_string_literal: true

class PgVersionMismatchHandler
  def initialize(app)
    @app = app
    @version = DockerEnv.pg_data_version
  end

  def call(env)
    if @version && @version != DockerEnv::NEEDED_PG_VERSION
      body = ApplicationController.renderer.render("application/pg_version_mismatch")
      [503, { "Content-Type" => "text/html; charset=UTF-8" }, [body]]
    else
      @app.call(env)
    end
  end
end
