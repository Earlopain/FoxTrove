# Contains all easily changeable settings
module Reverser
  module_function

  def app_name
    "Reverser"
  end

  def git_url
    "https://github.com/Earlopain/reverser"
  end

  # Controlls wether or not the logging should be intercepted
  def silence_log?
    true
  end

  # Matches either links or controller actions
  def log_ignore
    [
      "ActiveStorage::DiskController#show",
      "ActiveStorage::Blobs::RedirectController#show",
      "/rails/active_storage",
    ]
  end

  # How large should the generated thumbnails be
  # This is a bounding box
  def thumbnail_size
    300
  end

  # The server which handles similar images search
  # Must respond like https://github.com/danbooru/iqdb
  def iqdb_server
    "http://iqdb:5588"
  end

  def redis_url
    "redis://redis"
  end
end
