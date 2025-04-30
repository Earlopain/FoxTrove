require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FoxTrove
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    if Rails::VERSION::STRING >= "8.1.0"
      # Opt out of build-in variants. We don't use those.
      config.active_storage.variant_processor = nil
      config.active_storage.analyzers += [ActiveStorage::Analyzer::ImageAnalyzer::Vips]
    end

    config.active_job.queue_adapter = :good_job
    config.good_job.execution_mode = :external
    config.good_job.enable_cron = true
    config.good_job.cron = {
      purge_unattached: {
        cron: "0 * * * *", # every hour
        class: "PurgeUnattachedBlobsJob",
      },
      purge_log_events: {
        cron: "0 * * * *",
        class: "PurgeLogEventsJob",
      },
    }

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
