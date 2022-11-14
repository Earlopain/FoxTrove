# frozen_string_literal: true

class LogEventsController < ApplicationController
  def index
    @log_events = LogEvent.search(search_params).page(params[:page]).decorate
  end

  def show
    @log_event = LogEvent.find(params[:id]).decorate
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:loggable_id, :loggable_type, :action)
  end
end
