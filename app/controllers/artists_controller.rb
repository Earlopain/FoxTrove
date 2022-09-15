# frozen_string_literal: true

class ArtistsController < ApplicationController
  respond_to :html

  def new
    @artist = Artist.new
    respond_with(@artist)
  end

  def create
    Artist.transaction do
      @artist = Artist.create(artist_params)
      add_new_artist_urls_and_save(@artist) if @artist.valid?

      if @artist.errors.any?
        raise ActiveRecord::Rollback
      end
    end
    respond_with(@artist)
  end

  def index
    @artists = Artist.search(index_search_params).page params[:page]
  end

  def show
    @artist = Artist.includes(:artist_urls).find(params[:id])
    @submission_files = SubmissionFile
                        .search(instance_search_params.merge(artist_id: @artist.id))
                        .with_everything
                        .page params[:page]
    respond_with(@artist)
  end

  def edit
    @artist = Artist.includes(:artist_urls).find(params[:id])
    respond_with(@artist)
  end

  def update
    @artist = Artist.find(params[:id])
    @artist.update(artist_params)
    add_new_artist_urls_and_save(@artist)
    respond_with(@artist)
  end

  def destroy
    @artist = Artist.includes(artist_urls: { submissions: :submission_files }).find(params[:id])
    @artist.destroy
    redirect_to artists_path
  end

  def enqueue_all_urls
    @artist = Artist.find(params[:id])
    @artist.artist_urls.each(&:enqueue_scraping)
  end

  def update_all_iqdb
    @artist = Artist.find(params[:id])
    @artist.update_all_iqdb
  end

  private

  def artist_params
    permitted_params = %i[name url_string]

    params.fetch(:artist, {}).permit(permitted_params)
  end

  def index_search_params
    params.fetch(:search, {}).permit(:name, :url_identifier, :site_type)
  end

  def instance_search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end

  def add_new_artist_urls_and_save(artist)
    new_artist_urls = artist.url_string.lines.map(&:strip).compact_blank.map do |url|
      artist.add_artist_url(url)
    end
    return if artist.errors.any?

    new_artist_urls.each(&:enqueue_scraping)
    artist.save
  end
end
