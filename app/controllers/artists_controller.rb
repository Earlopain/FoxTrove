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
    add_new_artist_urls_and_save(@artist)
    respond_with(@artist)
  end

  def index
    @artists = Artist.all
  end

  def show
    @artist = Artist.includes(:artist_urls).find(params[:id])
    @submission_files = instance_search(search_params).for_url(search_params[:artist_urls]).for_artist(@artist.id).with_everything.page params[:page]
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
    @artist = Artist.find(params[:artist_id])
    @artist.artist_urls.each(&:enqueue_scraping)
  end

  private

  def artist_params
    permitted_params = %i[name url_string]

    params.fetch(:artist, {}).permit(permitted_params)
  end

  def search_params
    params.fetch(:search, {}).permit(:upload_status, :larger_only_treshold, artist_urls: [])
  end

  def instance_search(params)
    q = SubmissionFile
    if params[:upload_status].present?
      q = case params[:upload_status]
          when "larger_only"
            q.larger_only((params[:larger_only_treshold] || 10).to_i.kilobytes)
          when "exact_match"
            q.exact_match
          when "already_uploaded"
            q.already_uploaded
          when "not_uploaded"
            q.not_uploaded
          else
            q.none
          end
    end
    q
  end

  def add_new_artist_urls_and_save(artist)
    artist.valid?
    artist.url_string.lines.map(&:strip).reject(&:blank?).each do |url|
      result = Sites.from_url url

      if !result
        artist.errors.add(:url, " #{url} is not a supported url") unless result
        next
      elsif !result[:identifier_valid]
        artist.errors.add(:identifier, "#{result[:identifier]} is not valid for #{result[:site].display_name}")
        next
      end

      artist_url = artist.artist_urls.new(
        site_type: result[:site].enum_value,
        identifier_on_site: result[:identifier],
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
