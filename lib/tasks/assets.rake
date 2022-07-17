# frozen_string_literal: true

gem "ruby-vips"

namespace :assets do
  desc "Generate the icon spritemap"
  task generate_spritemap: :environment do
    icon_folder = Rails.public_path.join("icons")
    target_file = Rails.public_path.join("build/icons.png")
    icon_size = 64

    files = Dir.glob("#{icon_folder}/*.png")

    result = Vips::Image.thumbnail(files.first, icon_size)
    result = result.add_alpha unless result.has_alpha?

    files.drop(1).each do |file|
      image = Vips::Image.thumbnail(file, icon_size)
      image = image.add_alpha unless image.has_alpha?
      result = result.join(image, :vertical)
    end

    result.pngsave(target_file.to_s)
  end
end
