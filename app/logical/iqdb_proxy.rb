# Contains functions to interact with the iqdb server
module IqdbProxy
  class Error < RuntimeError; end

  VALID_CONTENT_TYPES = ["image/png", "image/jpeg"].freeze

  module_function

  # Makes the actual request to the iqdb server
  def make_request(path, request_type, params = {})
    url = URI.parse(Config.iqdb_server)
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

  def query_submission_file(submission_file)
    File.open(submission_file.sample.service.path_for(submission_file.sample.key)) do |f|
      # Remove the input submission file, we probably don't want it in the result
      query_file(f).reject { |entry| entry[:submission].id == submission_file.id }
    end
  end

  # Queries iqdb with the passed url
  def query_url(url)
    begin
      uri = Addressable::URI.parse url
    rescue Addressable::URI::InvalidURIError
      raise Error, "'#{url}' URL not valid"
    end
    raise Error, "'#{uri}' is not a valid url" if uri.host.blank? || !uri.scheme.in?(%w[http https])

    file = Tempfile.new(binmode: true)
    response = Sites.download_file file, uri

    raise Error, "Site responded with status code #{response.code}" if response.code != 200

    query_file(file)
  end

  # Queries iqdb with the passed file
  # The file is thumbnailed first before being sent to iqdb
  def query_file(input)
    mime_type = Marcel::MimeType.for input
    raise Error, "Unsupported file of type #{mime_type}" if VALID_CONTENT_TYPES.exclude? mime_type

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

  def self.process_iqbd_result(json, score_cutoff = 60)
    raise Error, "Server returned an error: #{json['message']}" unless json.is_a?(Array)

    json.filter! { |entry| entry["score"] >= score_cutoff }
    submission_ids = json.pluck("post_id")
    submissions = SubmissionFile.where(id: submission_ids).index_by(&:id)

    json.map do |entry|
      {
        score: entry["score"],
        submission: submissions[entry["post_id"]],
      }
    end
  end
end
