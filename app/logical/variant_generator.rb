# frozen_string_literal: true

module VariantGenerator
  def self.sample(attachment)
    input_path = ActiveStorage::Blob.service.path_for(attachment.key)
    output_file = Tempfile.new(["", ".jpg"])
    # TODO: Error handling
    case attachment.content_type
    when "image/jpeg", "image/png", "image/webp", "image/gif"
      image = Vips::Image.thumbnail(input_path, Config.thumbnail_size, height: Config.thumbnail_size, size: :down)
      image.jpegsave(output_file.path, Q: 90)
    when "video/mp4"
      target_size = "thumbnail,scale=w=#{Config.thumbnail_size}:h=#{Config.thumbnail_size}:force_original_aspect_ratio=decrease,pad=width=ceil(iw/2)*2:height=ceil(ih/2)*2"
      stdout, stderr, status = Open3.capture3("/usr/bin/ffmpeg", "-y", "-i", input_path, "-vf", target_size, "-frames:v", "1", output_file.path)
      raise StandardError, "Unable to thumbnail file\n#{stdout.chomp}\n\n#{stderr.chomp}" if status != 0
    else
      raise StandardError, "Unhandled content_type #{attachment.content_type}"
    end
    output_file
  end
end
