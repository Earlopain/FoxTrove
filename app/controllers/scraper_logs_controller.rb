class ScraperLogsController < ApplicationController
  def index
    @paginator, @scraper_logs = ScraperLog.search(search_params).paginate_and_decorate(params)
  end

  def show
    @scraper_log = ScraperLog.find(params.expect(:id)).decorate
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:site_type, :identifier, :request)
  end
end
