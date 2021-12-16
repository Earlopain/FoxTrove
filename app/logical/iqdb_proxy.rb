# Contains functions to interact with the iqdb server
module IqdbProxy
  class Error < RuntimeError; end

  module_function

  # Makes the actual request to the iqdb server
  def make_request(path, request_type, params = {})
    url = URI.parse(Reverser.iqdb_server)
    url.path = path
    HTTParty.send request_type, url, { body: params }
  end

  # Puts the passed submission into the iqdb server
  # This can both insert and update an submission
  def update_submission(submission)
    variant = submission.variant(:iqdb_thumb)
    File.open(variant.service.path_for(variant.key)) do |f|
      make_request "/images/#{submission_id}", :post, { file: f }
    end
  end

  # Removes the passed submission from iqdb
  def remove_submission(submission_id)
    make_request "/images/#{submission_id}", :delete
  end

  # Queries iqdb with the passed url
  def query_url(_image_url)
    raise Error, "Not implemented yet"
  end

  # Queries iqdb with the passed file
  # The file is thumbnailed first before being sent to iqdb
  def query_file(image)
    thumbnail = begin
      # iqdb only supports searching for jpg. Thumbnails are always jpg
      ImageProcessing::Vips.source(image).convert("jpg").resize_to_limit!(Reverser.thumbnail_size, Reverser.thumbnail_size)
    rescue Vips::Error
      raise Error, "Unsupported file"
    end
    response = make_request "/query", :post, { file: thumbnail }
    process_iqbd_result(response.parsed_response)
  end

  def self.process_iqbd_result(json, score_cutoff = 80)
    raise Error, "Server returned an error: #{json['message']}" unless json.is_a?(Array)

    json.filter! { |x| x["score"] >= score_cutoff }
    json
  end
end
