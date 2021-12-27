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
      name = "#{event.payload[:controller]}##{event.payload[:action]}"
      return if Reverser.log_ignore.any? { |ignore| name == ignore }

      original_start_processing event
    end

    # Completed 200 OK in 290ms (Views: 207.6ms | ActiveRecord: 40.6ms | Allocations: 163661)
    def process_action(event)
      name = "#{event.payload[:controller]}##{event.payload[:action]}"
      return if Reverser.log_ignore.any? { |ignore| name == ignore }

      original_process_action event
    end

    # Redirected to http://localhost:9000/rails/active_storage/disk/:key/sample
    def redirect_to(event)
      return if Reverser.log_ignore.any? { |ignore| event.payload[:request].fullpath.starts_with? ignore }

      original_redirect_to event
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
      return if Reverser.log_ignore.any? { |ignore| request.filtered_path.starts_with? ignore }

      original_started_request_message request
    end

    def logger
      @custom_logger
    end
  end
end

def silence(proc, on_load)
  ActiveSupport.on_load(on_load) do
    proc.call if Reverser.silence_log?
  end
end

silence active_storage, :active_storage_record
silence action_controller, :action_controller
rack.call
