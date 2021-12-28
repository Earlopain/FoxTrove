class IqdbController < ApplicationController
  def index
  end

  def search
    @result = IqdbProxy.query_file params[:file]
  end
end
