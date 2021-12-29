module Sites
  def self.download_file(outfile, uri, definition = nil)
    definition ||= Sites::Definitions.for_domain(uri.domain)
    headers = definition&.download_headers || {}
    response = HTTParty.get(uri, { headers: headers }) do |chunk|
      outfile.write(chunk)
    end
    outfile.rewind
    response
  end
end
