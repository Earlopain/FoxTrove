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

    result = Vips::Image.thumbnail(files.first, ICON_SIZE)
    result = result.add_alpha unless result.has_alpha?

    files.drop(1).each do |file|
      image = Vips::Image.thumbnail(file, ICON_SIZE)
      image = image.add_alpha unless image.has_alpha?
      result = result.join(image, :vertical)
    end

    result.pngsave(TARGET_FILE.to_s)
  end
end
