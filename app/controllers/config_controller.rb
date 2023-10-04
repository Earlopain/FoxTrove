# frozen_string_literal: true

class ConfigController < ApplicationController
  def index
  end

  def show
    @definition = Sites.from_enum(params[:id])
  end

  def modify
    custom_config = params.fetch(:config, {}).permit!
    custom_config[:scraper_request_rate_limit] = custom_config[:scraper_request_rate_limit].tr(",", ".").to_f if custom_config[:scraper_request_rate_limit]

    Config.write_custom_config(custom_config)
    Config.force_reload
    redirect_back fallback_location: config_index_path
  end
end
