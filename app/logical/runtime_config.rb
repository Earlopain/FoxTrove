# Anything here has an immediate effect without restarting
module RuntimeConfig
  module_function

  def app_name
    "Reverser"
  end

  def git_url
    "https://github.com/Earlopain/reverser"
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
end
