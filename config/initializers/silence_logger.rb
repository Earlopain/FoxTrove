# This is certainly something
active_storage = proc do
  # Filter out ActiveStorage related logging
  ActiveStorage::LogSubscriber.class_eval do
    # Disk Storage (0.8ms) Generated URL for file at key: :key (http://localhost:9000/rails/active_storage/disk/:key/sample)
    def service_url(event)
    end
  end
end

action_controller = proc do
  # Filter out ActionController related logging
  ActionController::LogSubscriber.class_eval do
    alias_method :original_start_processing, :start_processing
    alias_method :original_process_action, :process_action
    alias_method :original_redirect_to, :redirect_to

    # Processing by ApplicationController#show as HTML
    def start_processing(event)
      return if matches event

      original_start_processing event
    end

    # Completed 200 OK in 290ms (Views: 207.6ms | ActiveRecord: 40.6ms | Allocations: 163661)
    def process_action(event)
      return if matches event

      original_process_action event
    end

    def matches(event)
      Config.log_ignore.any? do |entry|
        name = entry.include?("#") ? "#{event.payload[:controller]}##{event.payload[:action]}" : event.payload[:controller]
        name == entry
      end
    end

    # Redirected to http://localhost:9000/rails/active_storage/disk/:key/sample
    def redirect_to(event)
      return if Config.log_ignore.any? { |ignore| event.payload[:request].fullpath.starts_with? ignore }

      original_redirect_to event
    end
  end
end

active_record = proc do
  ActiveRecord::LogSubscriber.class_eval do
    # Prevent logging of cached sql queries
    alias_method :original_sql, :sql
    def sql(event)
      if event.payload[:cached]
        self.class.runtime += event.duration
      else
        original_sql event
      end
    end

    # Because there is one more method called now
    def extract_query_source_location(locations)
      traces = backtrace_cleaner.clean(locations.lazy).first(2)
      return traces.last if traces.size == 2
    end
  end
end

action_view = proc do
  # Suppress all ActionView logging
  ActionView::LogSubscriber.class_eval do
    def render_template(event)
    end

    def render_partial(event)
    end

    def render_layout(event)
    end

    def render_collection(event)
    end
  end
end

# Prevents blank content from creating a line in the log
class CustomLogger
  def initialize(logger)
    @logger = logger
  end

  def info
    message = yield
    return if message.blank?

    @logger.info message
  end
end

rack = proc do
  Rails::Rack::Logger.class_eval do
    alias_method :original_started_request_message, :started_request_message
    alias_method :original_logger, :logger
    alias_method :original_initialize, :initialize

    def initialize(app, taggers = nil)
      original_initialize(app, taggers)
      @custom_logger = CustomLogger.new(Rails.logger)
    end

    # Started GET "/" for 192.168.96.1 at 2021-12-27 20:17:28 +0000
    def started_request_message(request)
      return if Config.log_ignore.any? { |ignore| request.filtered_path.starts_with? ignore }

      original_started_request_message request
    end

    def logger
      @custom_logger
    end
  end
end

def silence(proc, on_load)
  ActiveSupport.on_load(on_load) do
    proc.call if Config.silence_log?
  end
end

silence active_storage, :active_storage_record
silence action_controller, :action_controller
silence active_record, :active_record
silence action_view, :action_view
rack.call if Config.silence_log?
