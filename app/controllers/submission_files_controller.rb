# frozen_string_literal: true

class SubmissionFilesController < ApplicationController
  def backlog
    @submission_files = SubmissionFile.search(search_params)
                                      .with_everything
                                      .reorder(added_to_backlog_at: :desc)
                                      .where(in_backlog: true)
                                      .page params[:page]
  end

  def show
    @submission_file = SubmissionFile.find(params[:id])
    @artist_submission = @submission_file.artist_submission
    @similar = []
    @similar = IqdbProxy.query_submission_file(@submission_file) if @submission_file.can_iqdb?
  end

  def add_to_backlog
    submission_file = SubmissionFile.find(params[:id])
    submission_file.in_backlog = true
    submission_file.added_to_backlog_at = Time.current
    submission_file.save!
  end

  def remove_from_backlog
    submission_file = SubmissionFile.find(params[:id])
    submission_file.in_backlog = false
    submission_file.added_to_backlog_at = nil
    submission_file.save!
  end

  def update_e6_iqdb
    E6IqdbQueryWorker.perform_async params[:id], true
  end

  def search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end
end
