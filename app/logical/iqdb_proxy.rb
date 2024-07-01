# frozen_string_literal: true

# Contains functions to interact with the iqdb server
module IqdbProxy
  class Error < RuntimeError; end

  VALID_CONTENT_TYPES = ["image/png", "image/jpeg", "image/gif", "image/webp"].freeze
  IQDB_NUM_PIXELS = 128

  extend self

  # Puts the passed submission_file into the iqdb server
  # This can both insert and update an submission
  def update_submission(submission_file)
    response = client.post("/images/#{submission_file.id}", json: get_channels_data(submission_file.file_path_for(:sample)))
    raise StandardError, "iqdb request failed" if response.status != 200

    submission_file.iqdb_hash = [response.json["hash"]].pack("H*")
    submission_file.save
  end

  # Removes the passed submission_file from iqdb
  def remove_submission(submission_file)
    client.delete("/images/#{submission_file.id}")
  end

  def query_submission_file(submission_file)
    File.open(submission_file.file_path_for(:sample)) do |f|
      # Remove the input submission file, we probably don't want it in the result
      query_file(f).reject { |entry| entry[:submission_file].id == submission_file.id }
    end
  end

  # Queries iqdb with the passed url
  def query_url(url)
    Sites.download_file(url) { |file| query_file(file) }
  rescue Addressable::URI::InvalidURIError
    raise Error, "'#{url}' URL not valid"
  end

  # Queries iqdb with the passed file
  # The file is thumbnailed first before being sent to iqdb
  def query_file(input)
    mime_type = Marcel::MimeType.for input
    raise Error, "Unsupported file of type #{mime_type}" unless can_iqdb?(mime_type)

    response = client.post("/query", json: get_channels_data(input.path))
    process_iqbd_result(response.json)
  end

  def can_iqdb?(mime_type)
    VALID_CONTENT_TYPES.include?(mime_type)
  end

  private

  def client
    @client ||= HTTPX.with(origin: DockerEnv.iqdb_url, headers: { "content-type" => "application/json" })
  end

  def get_channels_data(file_path)
    thumbnail = Tempfile.new
    begin
      thumbnail = Vips::Image.thumbnail(file_path, IQDB_NUM_PIXELS, height: IQDB_NUM_PIXELS, size: :force)
    rescue Vips::Error
      raise Error, "Unsupported file"
    end
    r = []
    g = []
    b = []
    is_grayscale = thumbnail.bands == 1
    thumbnail.to_a.each do |data|
      data.each do |rgb|
        r << rgb[0]
        g << (is_grayscale ? rgb[0] : rgb[1])
        b << (is_grayscale ? rgb[0] : rgb[2])
      end
    end
    { channels: { r: r, g: g, b: b } }
  end

  def process_iqbd_result(json)
    raise Error, "Server returned an error: #{json['message']}" unless json.is_a?(Array)

    json.filter! { |entry| entry["score"] >= Config.similarity_cutoff }
    submission_ids = json.pluck("post_id")
    submissions = SubmissionFile.where(id: submission_ids).index_by(&:id)

    json.filter_map do |entry|
      next unless submissions[entry["post_id"]]

      {
        score: entry["score"],
        submission_file: submissions[entry["post_id"]],
      }
    end
  end
end
