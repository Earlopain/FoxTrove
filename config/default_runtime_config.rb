# Contains all easily changeable settings
module Reverser
  module_function

  # How large should the generated thumbnails be
  # This is a bounding box
  def thumbnail_size
    200
  end

  # The server which handles similar images search
  # Must respond like https://github.com/danbooru/iqdb
  def iqdb_server
    "http://iqdb:5588"
  end
end
