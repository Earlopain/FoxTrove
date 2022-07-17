class ArtistsController < ApplicationController
  respond_to :html

  def new
    @artist = Artist.new
    respond_with(@artist)
  end

  def create
    @artist = Artist.new(artist_params)
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
    params.fetch(:search, {}).permit(:name, :url_identifier)
  end

  def instance_search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end

  def add_new_artist_urls_and_save(artist)
    artist.valid?
    artist.url_string.lines.map(&:strip).compact_blank.each do |url|
      add_artist_url(artist, url)
    end
    return if artist.errors.any?

    artist.artist_urls.each(&:save!)
    artist.save
  end

  def add_artist_url(artist, url)
    result = Sites.from_url url

    if !result
      artist.errors.add(:url, " #{url} is not a supported url") unless result
      return
    elsif !result[:identifier_valid]
      artist.errors.add(:identifier, "#{result[:identifier]} is not valid for #{result[:site].display_name}")
      return
    end

    artist_url = artist.artist_urls.new(
      site_type: result[:site].enum_value,
      url_identifier: result[:identifier],
      created_at_on_site: Time.current,
      about_on_site: "",
    )
    artist_url.validate
    artist_url.errors.full_messages.each do |msg|
      artist.errors.add(:url, "#{url} is not valid: #{msg}")
    end
  end
end
