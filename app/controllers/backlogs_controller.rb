class BacklogsController < ApplicationController
  before_action :member_only

  def create
    Backlog.create!(
      user_id: current_user.id,
      submission_file_id: params[:submission_file_id]
    )
  end

  def destroy
    backlog = Backlog.find(params[:id])
    raise User::PrivilegeError if backlog.user != current_user

    backlog.destroy
  end
end
