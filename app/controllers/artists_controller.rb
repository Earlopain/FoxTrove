# frozen_string_literal: true

class ArtistsController < ApplicationController
  def index
    @pagy, @artists = Artist.includes(:artist_urls).search(index_search_params).pagy(params)

    @artist_urls_count = ArtistUrl.select(:artist_id)
      .where(artist: @artists).group(:artist_id).count
    @submissions_count = ArtistSubmission.select(:artist_id).joins(:artist_url)
      .where(artist_url: { artist: @artists }).group(:artist_id).count

    base = SubmissionFile.select(:artist_id).joins(artist_submission: :artist_url)
      .where("artist_url.artist_id": @artists.map(&:id)).group("artist_url.artist_id")
    @submission_files_count = base.count
    @not_uploaded_count = base.search(upload_status: "not_uploaded").reorder("").count
    @larger_size_count = base.search(upload_status: "larger_only_filesize_percentage").reorder("").count
    @larger_dimensions_count = base.search(upload_status: "larger_only_dimensions").reorder("").count
  end

  def show
    @artist = Artist.includes(:artist_urls).find(params[:id])
    @search_params = instance_search_params.merge(artist_id: @artist.id)
    @pagy, @submission_files = SubmissionFile.search(@search_params).with_everything.pagy(params)
  end

  def new
    @artist = Artist.new
  end

  def edit
    @artist = Artist.includes(:artist_urls).find(params[:id])
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
    @artist.enqueue_all_urls
  end

  def enqueue_everything
    Artist.find_each(&:enqueue_all_urls)
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
