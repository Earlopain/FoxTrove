# This is certainly something
ActiveSupport.on_load(:action_controller) do
  if Reverser.silence_log?
    module ActiveStorage
      # Filter out ActiveStorage related logging
      class LogSubscriber < ActiveSupport::LogSubscriber
        # Disk Storage (0.8ms) Generated URL for file at key: :key (http://localhost:9000/rails/active_storage/disk/:key/sample)
        def service_url(event)
        end
      end
    end

    module ActionController
      # Filter out ActionController related logging
      class LogSubscriber < ActiveSupport::LogSubscriber
        alias original_start_processing start_processing
        alias original_process_action process_action
        alias original_redirect_to redirect_to

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

    module Rails
      module Rack
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

        # Filter out logging from rack itself
        class Logger < ActiveSupport::LogSubscriber
          CUSTOM_LOGGER = CustomLogger.new(logger)
          alias original_started_request_message started_request_message
          alias original_logger logger

          # Started GET "/" for 192.168.96.1 at 2021-12-27 20:17:28 +0000
          def started_request_message(request)
            return if Reverser.log_ignore.any? { |ignore| request.filtered_path.starts_with? ignore }

            original_started_request_message request
          end

          def logger
            CUSTOM_LOGGER
          end
        end
      end
    end
  end
end
