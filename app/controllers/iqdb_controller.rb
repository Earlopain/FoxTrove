# frozen_string_literal: true

class IqdbController < ApplicationController
  def index
  end

  def search
    @result = if params[:url].present?
                IqdbProxy.query_url params[:url]
              elsif params[:file]
                IqdbProxy.query_file params[:file]
              else
                []
              end
  end
end
