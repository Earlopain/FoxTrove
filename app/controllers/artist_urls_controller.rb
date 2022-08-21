# frozen_string_literal: true

class ArtistUrlsController < ApplicationController
  def enqueue
    artist_url = ArtistUrl.find(params[:id])
    artist_url.enqueue_scraping
  end
end
