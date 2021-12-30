class DebugController < ApplicationController
  def index
  end

  def reload_config
    Config.force_reload
    redirect_to debug_path
  end
end
