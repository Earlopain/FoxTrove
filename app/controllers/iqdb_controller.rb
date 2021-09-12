class IqdbController < ApplicationController
  def index
  end

  def search
    @results = IqdbProxy.query_file params[:file]
  end
end
