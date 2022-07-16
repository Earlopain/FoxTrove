class SubmissionFilesController < ApplicationController
  def index
    @submission_files = SubmissionFile.search(search_params)
                                      .with_everything
                                      .reorder("backlogs.created_at desc")
                                      .select("submission_files.*, backlogs.created_at")
                                      .where("backlogs.submission_file_id = submission_files.id")
                                      .page params[:page]
  end

  def show
    @submission_file = SubmissionFile.find(params[:id])
    @artist_submission = @submission_file.artist_submission
    @similar = IqdbProxy.query_submission_file(@submission_file)
  end

  def update_e6_iqdb
    E6IqdbQueryWorker.perform_async params[:id], true
  end

  def search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end
end
