class LogEventsController < ApplicationController
  def index
    @paginator, @log_events = LogEvent.search(search_params).paginate_and_decorate(params)
  end

  def show
    @log_event = LogEvent.find(params[:id]).decorate
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:loggable_id, :loggable_type, :action, :payload)
  end
end
