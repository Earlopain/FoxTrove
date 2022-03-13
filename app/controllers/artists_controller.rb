class ArtistsController < ApplicationController
  respond_to :html
  before_action :member_only, only: %i[create new]
  before_action :admin_only, only: %i[enqueue_all_urls destroy]

  def new
    @artist = Artist.new(artist_params)
    respond_with(@artist)
  end

  def create
    @artist = Artist.new(artist_params)
    @artist.creator = current_user
    add_new_artist_urls_and_save(@artist)
    respond_with(@artist)
  end

  def index
    @artists = Artist.search(index_search_params).page params[:page]
  end

  def show
    @artist = Artist.includes(:artist_urls).find(params[:id])
    @submission_files = SubmissionFile
                        .search(instance_search_params.merge({ artist_id: @artist.id }))
                        .with_everything(current_user.id)
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
    params.fetch(:search, {}).permit(:name, :url_identifier)
  end

  def instance_search_params
    params.fetch(:search, {}).permit(:upload_status, :larger_only_filesize_treshold, :content_type, { artist_url_id: [] })
  end

  def add_new_artist_urls_and_save(artist)
    artist.valid?
    artist.url_string.lines.map(&:strip).compact_blank.each do |url|
      result = Sites.from_url url

      if !result
        artist.errors.add(:url, " #{url} is not a supported url") unless result
        next
      elsif !result[:identifier_valid]
        artist.errors.add(:identifier, "#{result[:identifier]} is not valid for #{result[:site].display_name}")
        next
      end

      artist_url = artist.artist_urls.new(
        creator: current_user,
        site_type: result[:site].enum_value,
        url_identifier: result[:identifier],
        created_at_on_site: Time.current,
        about_on_site: ""
      )
      artist_url.validate
      artist_url.errors.full_messages.each do |msg|
        artist.errors.add(:url, "#{url} is not valid: #{msg}")
      end
    end
    return if artist.errors.any?

    artist.artist_urls.each(&:save!)
    artist.save
  end
end
