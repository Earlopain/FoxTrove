class SubmissionFilesController < ApplicationController
  def show
    @submission_file = SubmissionFile.find(params[:id])
    @artist_submission = @submission_file.artist_submission
    @similar = IqdbProxy.query_submission_file(@submission_file)
  end

  def update_e6_iqdb
    E6IqdbQueryWorker.perform_async params[:submission_file_id], true
  end
end
