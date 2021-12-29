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

  def self.method_missing(method)
    if custom_config.keys.include? method.to_s
      custom_config[method.to_s]
    elsif Static.respond_to? method
      Static.send method
    else
      RuntimeConfig.send method
    end
  end

  def self.custom_config
    @custom_config ||= if ENV.keys.include? "REVERSER_CUSTOM_CONFIG_PATH"
                         YAML.load_file(ENV["REVERSER_CUSTOM_CONFIG_PATH"])
                       else
                         {}
                       end
  end
end
