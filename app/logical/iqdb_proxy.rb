# Contains functions to interact with the iqdb server
module IqdbProxy
  class Error < RuntimeError; end

  VALID_CONTENT_TYPES = ["image/png", "image/jpeg"].freeze

  module_function

  # Makes the actual request to the iqdb server
  def make_request(path, request_type, params = {})
    url = URI.parse(Reverser.iqdb_server)
    url.path = path
    HTTParty.send request_type, url, { body: params }
  end

  # Puts the passed submission_file into the iqdb server
  # This can both insert and update an submission
  def update_submission(submission_file)
    sample = submission_file.sample
    File.open(sample.service.path_for(sample.key)) do |f|
      make_request "/images/#{submission_file.id}", :post, { file: f }
    end
  end

  # Removes the passed submission_file from iqdb
  def remove_submission(submission_file)
    make_request "/images/#{submission_file.id}", :delete
  end

  # Queries iqdb with the passed url
  def query_url(_image_url)
    raise Error, "Not implemented yet"
  end

  # Queries iqdb with the passed file
  # The file is thumbnailed first before being sent to iqdb
  def query_file(input)
    thumbnail = Tempfile.new
    begin
      # iqdb only supports searching for jpg. Thumbnails are always jpg
      VariantGenerator.image_thumb input.path, thumbnail, 150, height: 150, size: :force
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
