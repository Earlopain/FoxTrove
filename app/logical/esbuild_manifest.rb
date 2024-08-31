module EsbuildManifest
  FILE_LOCATION = Rails.public_path.join("build/manifest.json")

  module_function

  def [](entry)
    raise StandardError, "Entrypoint '#{entry}' not found" if entrypoints[entry].blank? && !Rails.env.test?

    "/#{entrypoints[entry]}"
  end

  def entrypoints
    @entrypoints ||= parse
  end

  def parse
    data = JSON.parse(FILE_LOCATION.read)
    available_entrypoints = data["outputs"].select { |_k, v| v["entryPoint"].present? }
    result = {}
    available_entrypoints.each do |entrypoint_path, entrypoint_data|
      relative_path = relative_to_public(entrypoint_path)
      entrypoint_name = Pathname.new(entrypoint_data["entryPoint"]).basename
      result[entrypoint_name.to_s] = relative_path.to_s
      result[entrypoint_name.sub_ext(".css").to_s] = relative_to_public(entrypoint_data["cssBundle"]).to_s if entrypoint_data["cssBundle"]
    end
    result
  rescue Errno::ENOENT, JSON::ParserError
    {}
  end

  def reset_cache
    @entrypoints = nil
  end

  def relative_to_public(input)
    Rails.root.join(input).relative_path_from(Rails.public_path)
  end
end
