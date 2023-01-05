# frozen_string_literal: true

class ArchiveImportsController < ApplicationController
  def new
  end

  def create
    @archive = Archives::Tumblr.new(params[:import][:file])
    @archive.import_submission_files
  end
end
