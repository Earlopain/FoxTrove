# frozen_string_literal: true

class TumblrImportsController < ApplicationController
  def index
  end

  def create
    @archive = TumblrArchive.new(params[:import][:file])
    @archive.import_submission_files
  end
end
