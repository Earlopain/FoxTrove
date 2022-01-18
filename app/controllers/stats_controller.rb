class StatsController < ApplicationController
  def index
    @artist_urls = ArtistUrl.where id: SidekiqStats.active_urls
  end
end
