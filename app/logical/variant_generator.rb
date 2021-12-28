module VariantGenerator
  def self.sample(attachment)
    path = ActiveStorage::Blob.service.path_for(attachment.key)
    file = Tempfile.new
    # TODO: Error handling
    case attachment.content_type
    when "image/jpeg", "image/png"
      image_thumb(path, file, Config.thumbnail_size, height: Config.thumbnail_size, size: :down)
    when "video/mp4"
      params = mp4_conversion_parameters(path, file.path, [Config.thumbnail_size, Config.thumbnail_size])
      stdout, stderr, status = Open3.capture3("/usr/bin/ffmpeg", *params)
      raise StandardError, "unable to transcode files\n#{stdout.chomp}\n\n#{stderr.chomp}" if status != 0
    else
      raise StandardError, "Unhanlded content_type #{attachment.content_type}"
    end
    file
  end

  def self.image_thumb(input_path, outfile, width, **options)
    image = Vips::Image.thumbnail(input_path, width, **options)
    image.jpegsave(outfile.path, Q: 90)
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
