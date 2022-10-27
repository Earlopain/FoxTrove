# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

require "open3"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Reverser
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.active_record.schema_format = :sql
    config.active_job.queue_adapter = :good_job
    config.good_job.execution_mode = :external

    config.action_controller.action_on_unpermitted_parameters = :raise

    config.cache_store = :file_store, Rails.root.join("tmp/file_store")
    config.action_controller.cache_store = config.cache_store

    config.logger = ActiveSupport::Logger.new($stdout)
    if GoodJob::CLI.within_exe?
      config.log_level = :info
    end
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
