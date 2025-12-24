class ConfigController < ApplicationController
  def index
  end

  def show
    @definition = Sites.from_enum(params[:id])
    raise ActiveRecord::RecordNotFound unless @definition
  end

  def modify
    custom_config = params.fetch(:config, {}).permit!

    Config.write_custom_config(custom_config)
    Config.reset_cache
    redirect_back_or_to(config_index_path)
  end
end
