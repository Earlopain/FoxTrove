module VariantGenerator
  THUMBNAIL_SIZE = 300

  def self.sample(input_path, content_type)
    output_file = Tempfile.new(["", ".jpg"])
    # TODO: Error handling
    case content_type
    when "image/jpeg", "image/png", "image/webp", "image/gif"
      image = Vips::Image.thumbnail(input_path, THUMBNAIL_SIZE, height: THUMBNAIL_SIZE, size: :down)
      image.jpegsave(output_file.path, Q: 90)
    when "video/mp4", "video/webm", "video/quicktime"
      target_size = "thumbnail,scale=w=#{THUMBNAIL_SIZE}:h=#{THUMBNAIL_SIZE}:force_original_aspect_ratio=decrease,pad=width=ceil(iw/2)*2:height=ceil(ih/2)*2"
      stdout, stderr, status = Open3.capture3("/usr/bin/ffmpeg", "-y", "-i", input_path, "-vf", target_size, "-frames:v", "1", output_file.path)
      raise StandardError, "Unable to thumbnail file\n#{stdout.chomp}\n\n#{stderr.chomp}" if status != 0
    else
      raise StandardError, "Unhandled content_type #{content_type}"
    end
    output_file
  end
end
