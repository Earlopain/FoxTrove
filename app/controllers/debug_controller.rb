class DebugController < ApplicationController
  def index
  end

  def reload_config
    Config.force_reload
    redirect_to debug_path
  end

  def generate_spritemap
    `bin/rails assets:generate_spritemap`
    redirect_to debug_path
  end

  def seed_db
    `bin/rails db:seed`
    redirect_to debug_path
  end

  def iqdb_readd
    `bin/rails iqdb:readd`
    redirect_to debug_path
  end
end
