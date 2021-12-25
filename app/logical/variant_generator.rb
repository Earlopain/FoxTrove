module VariantGenerator
  def self.sample(attachment)
    path = ActiveStorage::Blob.service.path_for(attachment.key)
    file = Tempfile.new
    # TODO: Error handling
    case attachment.content_type
    when "image/jpeg", "image/png", "image/gif"
      image = Vips::Image.thumbnail(path, Reverser.thumbnail_size, height: Reverser.thumbnail_size, size: :down)
      image.jpegsave(file.path, Q: 90)
    when "video/mp4"
      params = mp4_conversion_parameters(path, file.path, [Reverser.thumbnail_size, Reverser.thumbnail_size])
      stdout, stderr, status = Open3.capture3("/usr/bin/ffmpeg", *params)
      raise StandardError, "unable to transcode files\n#{stdout.chomp}\n\n#{stderr.chomp}" if status != 0
    end
    file
  end

  def self.iqdb_thumb(attachment)
    path = ActiveStorage::Blob.service.path_for(attachment.key)
    image = Vips::Image.thumbnail(path, 128, height: 128, size: :force)
    file = Tempfile.new
    image.jpegsave(file.path, Q: 90)
    file
  end

  def self.mp4_conversion_parameters(in_path, out_path, dimensions)
    target_size = "scale=w=#{dimensions[0]}:h=#{dimensions[1]}:force_original_aspect_ratio=decrease,pad=width=ceil(iw/2)*2:height=ceil(ih/2)*2"
    [
      "-i",
      in_path,
      "-vf",
      target_size,
      "-y",
      "-c:v",
      "libx264",
      "-pix_fmt",
      "yuv420p",
      "-profile:v",
      "main",
      "-preset",
      "fast",
      "-crf",
      "27",
      "-b:v",
      "3M",
      "-threads",
      "4",
      "-max_muxing_queue_size",
      "4096",
      "-c:a",
      "aac",
      "-b:a",
      "128k",
      "-map_metadata",
      "-1",
      "-movflags",
      "+faststart",
      "-f",
      "mp4",
      out_path,
    ]
  end
end
