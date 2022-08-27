# frozen_string_literal: true

class LogEventsController < ApplicationController
  def index
    @log_events = LogEventDecorator.decorate_collection(LogEvent.search(search_params).page(params[:page]))
  end

  def show
    @log_event = LogEventDecorator.decorate(LogEvent.find(params[:id]))
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:loggable_id, :loggable_type, :action)
  end
end
