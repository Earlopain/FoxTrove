# frozen_string_literal: true

class SubmissionFilesController < ApplicationController
  def show
    @submission_file = SubmissionFile.find(params[:id])
    @artist_submission = @submission_file.artist_submission
    @similar = []
    @similar = IqdbProxy.query_submission_file(@submission_file) if @submission_file.can_iqdb?
  end

  def index
    @submission_files = SubmissionFile.search(search_params).with_everything.page(params[:page])
  end

  def modify_backlog
    submission_file = SubmissionFile.find(params[:id])
    in_backlog = params[:type] == "add"
    submission_file.update(added_to_backlog_at: in_backlog ? Time.current : nil)
  end

  def modify_hidden
    submission_file = SubmissionFile.find(params[:id])
    hide_from_search = params[:type] == "add"
    submission_file.update(hidden_from_search_at: hide_from_search ? Time.current : nil)
  end

  def update_e6_iqdb
    submission_file = SubmissionFile.find(params[:id])
    E6IqdbQueryWorker.perform_async submission_file.id
    similar = IqdbProxy.query_submission_file(submission_file).pluck(:submission)
    similar.each { |s| s.e6_iqdb_entries.destroy_all }
    similar.each { |s| E6IqdbQueryWorker.perform_async s.id } # rubocop:disable Style/CombinableLoops
  end

  def backlog
    @submission_files = SubmissionFile.search(search_params.merge(in_backlog: true))
                                      .with_everything
                                      .reorder(added_to_backlog_at: :desc)
                                      .page params[:page]
  end

  def hidden
    @submission_files = SubmissionFile.search(search_params.merge(hidden_from_search: true))
                                      .with_everything
                                      .reorder(hidden_from_search_at: :desc)
                                      .page params[:page]
  end

  private

  def search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end
end
