class UsersController < ApplicationController
  respond_to :html

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    respond_with(@user)
  end

  def create
    @user = User.new(user_params)
    @user.last_logged_in_at = Time.zone.now
    @user.last_ip_addr = current_ip_addr
    @user.level = :member
    @user.save
    session[:user_id] = user.id if @user.errors.empty?
    respond_with(@user)
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

  def user_params
    permitted_params = %i[name api_key password password_confirmation]

    params.fetch(:user, {}).permit(permitted_params)
  end
end
