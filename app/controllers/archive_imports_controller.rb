# frozen_string_literal: true

class ArchiveImportsController < ApplicationController
  def new
  end

  def create
    @archive = Archives.detect(params[:import][:file])
    @archive.import(params[:import][:artist_id].to_i, params[:import][:source_url])
  end
end
