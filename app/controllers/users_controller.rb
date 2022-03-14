class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def backlog
    @user = User.find(params[:id])
    @submission_files = SubmissionFile.search(backlog_search_params.merge(backlog_user_id: params[:id]))
                                      .with_everything(params[:id])
                                      .reorder("backlogs.created_at desc")
                                      .select("submission_files.*, backlogs.created_at")
                                      .page params[:page]
  end

  private

  def backlog_search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end
end
