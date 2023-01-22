# frozen_string_literal: true

class ArtistUrlsController < ApplicationController
  def show
    @artist_url = ArtistUrl.find(params[:id])
    redirect_to artist_path(@artist_url.artist, search: { artist_url_id: [params[:id]] })
  end

  def enqueue
    artist_url = ArtistUrl.find(params[:id])
    artist_url.enqueue_scraping
  end
end
