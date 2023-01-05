# frozen_string_literal: true

class ArchiveImportsController < ApplicationController
  def new
  end

  def create
    @archive = Archives.detect(params[:import][:file])
    @archive.import
  end
end
