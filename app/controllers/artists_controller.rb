class ArtistsController < ApplicationController
  respond_to :html

  def new
    @artist = Artist.new(artist_params)
    respond_with(@artist)
  end

  def create
    @artist = Artist.create(artist_params)
    respond_with(@artist)
  end

  def index
    @artists = Artist.all
  end

  def show
    @artist = Artist.find(params[:id])
    respond_with(@artist)
  end

  private

  def artist_params
    permitted_params = %i[name]

    params.fetch(:artist, {}).permit(permitted_params)
  end
end
