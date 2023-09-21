# frozen_string_literal: true

class SubmissionFilesController < ApplicationController
  respond_to :json, only: %i[hide_many backlog_many enqueue_many]

  def index
    @search_params = search_params
    @pagy, @submission_files = SubmissionFile.search(@search_params).with_everything.pagy(params)
  end

  def show
    @submission_file = SubmissionFile.find(params[:id])
    @artist_submission = @submission_file.artist_submission
    @similar = []
    @similar = IqdbProxy.query_submission_file(@submission_file) if @submission_file.can_iqdb? && @submission_file.sample_generated?
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

  def update_e6_posts
    submission_file = SubmissionFile.find(params[:id])
    submission_file.update_e6_posts(priority: E6IqdbQueryJob::PRIORITIES[:immediate])
  end

  def update_matching_e6_posts
    UpdateMatchingE6PostsJob.perform_later(search_params)
  end

  def backlog
    @search_params = search_params.merge(in_backlog: true)
    @pagy, @submission_files = SubmissionFile.search(@search_params)
      .with_everything
      .reorder(added_to_backlog_at: :desc)
      .pagy(params)
  end

  def hidden
    @search_params = search_params.merge(hidden_from_search: true)
    @pagy, @submission_files = SubmissionFile.search(@search_params)
      .with_everything
      .reorder(hidden_from_search_at: :desc)
      .pagy(params)
  end

  def hide_many
    SubmissionFile.where(id: params[:ids], hidden_from_search_at: nil).find_each do |submission_file|
      submission_file.update(hidden_from_search_at: Time.current)
    end
  end

  def backlog_many
    SubmissionFile.where(id: params[:ids], added_to_backlog_at: nil).find_each do |submission_file|
      submission_file.update(added_to_backlog_at: Time.current)
    end
  end

  def enqueue_many
    SubmissionFile.where(id: params[:ids]).find_each(&:update_e6_posts)
  end

  private

  def search_params
    params.fetch(:search, {}).permit(SubmissionFile.search_params)
  end
end
