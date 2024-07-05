# frozen_string_literal: true

module IconGenerator
  module_function

  ICON_FOLDER = Rails.public_path.join("icons")
  TARGET_FILE = Rails.public_path.join("icons.png")
  ICON_SIZE = 64

  def run
    files = Dir.glob("#{ICON_FOLDER}/*.png").sort_by do |path|
      index, = File.basename(path).split("-")
      index.to_i
    end

    thumbs = files.map do |file|
      thumb = Vips::Image.thumbnail(file, ICON_SIZE)
      thumb = thumb.add_alpha unless thumb.has_alpha?
      thumb
    end

    icons = thumbs.reduce { |result, thumb| result.join(thumb, :vertical) }
    icons.pngsave(TARGET_FILE.to_s)
  end
end
