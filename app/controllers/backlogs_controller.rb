class BacklogsController < ApplicationController
  def create
    Backlog.create!(
      submission_file_id: params[:submission_file_id]
    )
  end

  def destroy
    backlog = Backlog.find(params[:id])
    backlog.destroy
  end
end
