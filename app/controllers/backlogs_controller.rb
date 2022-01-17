class BacklogsController < ApplicationController
  def index
    @submission_files = SubmissionFile.with_everything.joins(:backlogs).where(backlogs: { user_id: CurrentUser.id }).page params[:page]
  end
end
