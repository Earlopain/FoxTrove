module Config
  module Static
    module_function

    # Controls wether or not the logging should be intercepted
    def silence_log?
      true
    end

    # Matches either links or controller actions
    def log_ignore
      [
        "ActiveStorage::DiskController#show",
        "ActiveStorage::Blobs::RedirectController#show",
        "/rails/active_storage",
        "/sidekiq",
      ]
    end

    def redis_url
      "redis://redis"
    end
  end

  def self.method_missing(method, *args)
    return Static.send method, *args if Static.respond_to? method

    RuntimeConfig.send method, *args
  end
end
