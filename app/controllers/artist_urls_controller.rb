class ArtistUrlsController < ApplicationController
  def index
    @paginator, @artist_urls = ArtistUrl.search(index_search_params).paginate(params)
  end

  def show
    @artist_url = ArtistUrl.find(params[:id])
    redirect_to artist_path(@artist_url.artist, search: { artist_url_id: [params[:id]] })
  end

  def destroy
    artist_url = ArtistUrl.includes(submissions: :submission_files).find(params[:id])
    artist_url.destroy
    redirect_to artist_urls_path
  end

  def enqueue
    artist_url = ArtistUrl.find(params[:id])
    artist_url.enqueue_scraping
  end

  private

  def index_search_params
    params.fetch(:search, {}).permit(:site_type, :url_identifier, :api_identifier, :missing_api_identifier)
  end
end
