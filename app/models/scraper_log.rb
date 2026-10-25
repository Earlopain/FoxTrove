class ScraperLog < ApplicationRecord
  PARAMETER_FILTER = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

  def self.add!(artist_url, request = {})
    create!(
      site_type: artist_url.site_type,
      api_identifier: artist_url.api_identifier,
      url_identifier: artist_url.url_identifier,
      request: PARAMETER_FILTER.filter(request),
    )
  end

  def definition
    Sites.from_enum(site_type)
  end

  def self.search(params)
    q = all
    q = q.attribute_matches(params[:site_type], :site_type)
    q = q.attribute_matches(params[:identifier], :url_identifier).or(q.attribute_matches(params[:identifier], :api_identifier))
    q = q.attribute_matches(params[:request], :request)

    q.order(id: :desc)
  end
end
