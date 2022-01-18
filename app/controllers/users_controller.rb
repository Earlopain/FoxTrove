class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def backlog
    @user = User.find(params[:id])
    @submission_files = SubmissionFile.with_everything(params[:id]).where(backlogs: { user_id: params[:id] }).order("backlogs.created_at desc").page params[:page]
  end
end
