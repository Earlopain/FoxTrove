module ImageUtils
  module_function

  # https://www.color.org/srgbprofiles.xalter
  SRGB_PROFILE = Rails.root.join("config/sRGB_v4_ICC_preference.icc").to_s.freeze
  # https://libvips.github.io/libvips/API/current/libvips-resample.html#vips-thumbnail
  THUMBNAIL_OPTIONS = { size: :down, linear: false, no_rotate: true, export_profile: SRGB_PROFILE, import_profile: SRGB_PROFILE }.freeze
  THUMBNAIL_OPTIONS_NO_ICC = { size: :down, linear: false, no_rotate: true, export_profile: SRGB_PROFILE }.freeze
  # https://libvips.github.io/libvips/API/current/VipsForeignSave.html#vips-jpegsave
  JPEG_OPTIONS = { background: 0, strip: true, interlace: true, optimize_coding: true }.freeze

  # https://github.com/libvips/libvips/wiki/HOWTO----Image-shrinking
  # https://libvips.github.io/libvips/API/current/Using-vipsthumbnail.md.html
  def thumbnail(file)
    output_file = Tempfile.new
    begin
      resized_image = Vips::Image.thumbnail(file.path, Reverser.thumbnail_size, **THUMBNAIL_OPTIONS)
    rescue Vips::Error => e
      raise e unless e.message =~ /icc_transform/i

      resized_image = Vips::Image.thumbnail(file.path, Reverser.thumbnail_size, **THUMBNAIL_OPTIONS_NO_ICC)
    end
    resized_image.jpegsave(output_file.path, Q: 90, **JPEG_OPTIONS)

    output_file
  end

  def corrupt?(filename)
    image = Vips::Image.new_from_file(filename, fail: true)
    image.stats
    false
  rescue StandardError
    true
  end
end
