class SubmissionFilesController < ApplicationController
  def index
    @search_params = search_params
    @paginator, @submission_files = SubmissionFile.search(@search_params).with_everything.paginate(params)
  end

  def show
    @submission_file = SubmissionFile.find(params.expect(:id))
    @artist_submission = @submission_file.artist_submission
    @similar = []
    @similar = IqdbProxy.query_submission_file(@submission_file) if @submission_file.can_iqdb? && @submission_file.sample_generated?
  end

  def modify_backlog
    submission_file = SubmissionFile.find(params.expect(:id))
    in_backlog = params[:type] == "add"
    submission_file.update(added_to_backlog_at: in_backlog ? Time.current : nil)
  end

  def modify_hidden
    submission_file = SubmissionFile.find(params.expect(:id))
    hide_from_search = params[:type] == "add"
    submission_file.update(hidden_from_search_at: hide_from_search ? Time.current : nil)
  end

  def update_e6_posts
    submission_file = SubmissionFile.find(params.expect(:id))
    submission_file.update_e6_posts(priority: E6IqdbQueryJob::PRIORITIES[:immediate])
  end

  def update_matching_e6_posts
    UpdateMatchingE6PostsJob.perform_later(search_params)
  end

  def backlog
    @search_params = search_params.merge(in_backlog: true)
    @paginator, @submission_files = SubmissionFile.search(@search_params)
      .with_everything
      .reorder(added_to_backlog_at: :desc)
      .paginate(params)
  end

  def hidden
    @search_params = search_params.merge(hidden_from_search: true)
    @paginator, @submission_files = SubmissionFile.search(@search_params)
      .with_everything
      .reorder(hidden_from_search_at: :desc)
      .paginate(params)
  end

  def hide_many
    SubmissionFile.where(id: params[:ids], hidden_from_search_at: nil).find_each do |submission_file|
      submission_file.update(hidden_from_search_at: Time.current)
    end
  end

  def unhide_many
    SubmissionFile.where(id: params[:ids]).where.not(hidden_from_search_at: nil).find_each do |submission_file|
      submission_file.update(hidden_from_search_at: nil)
    end
  end

  def backlog_many
    SubmissionFile.where(id: params[:ids], added_to_backlog_at: nil).find_each do |submission_file|
      submission_file.update(added_to_backlog_at: Time.current)
    end
  end

  def unbacklog_many
    SubmissionFile.where(id: params[:ids]).where.not(added_to_backlog_at: nil).find_each do |submission_file|
      submission_file.update(added_to_backlog_at: nil)
    end
  end

  def enqueue_many
    SubmissionFile.where(id: params[:ids]).find_each(&:update_e6_posts)
  end

  def import
    params = import_params
    respond_to do |format|
      format.json do
        artist = Artist.find_or_create_by!(name: params[:artist_name])
        artist_url = artist.artist_urls.find_or_create_by!(
          site_type: "manual",
          url_identifier: params[:artist_url],
        )
        artist_submission = artist_url.submissions.find_or_create_by!(
          identifier_on_site: params[:submission][:url],
        ) do |submission|
          submission.title_on_site = params[:submission][:title]
          submission.description_on_site = params[:submission][:description]
          submission.created_at_on_site = params[:submission][:created_at]
        end

        if (existing = artist_submission.submission_files.find_by(file_identifier: params[:file][:url]))
          return render json: existing
        end

        submission_file = SubmissionFile.from_attachable(
          attachable: params[:file][:blob],
          artist_submission: artist_submission,
          url: params[:file][:url],
          created_at: params[:submission][:created_at],
          file_identifier: params[:file][:url],
        )

        render json: submission_file
      end
    end
  end

  private

  def search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end

  def import_params
    import = params.expect(
      import: [
        :artist_name,
        :artist_url,
        { submission: %i[created_at url title description] },
        { file: %i[url blob] },
      ],
    )
    import.require(%i[artist_name artist_url submission file])
    import
  end
end
