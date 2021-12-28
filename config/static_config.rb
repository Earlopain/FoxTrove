# Anything defined here needs a server restart to take effect
module Reverser
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

  def method_missing(method, *args)
    return Reverser.send method, *args if Reverser.respond_to? method

    RuntimeConfig.send method, *args
  end
end
