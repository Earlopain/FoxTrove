# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :normalize_params
  around_action :with_time_zone

  rescue_from Exception, with: :rescue_exception

  def normalize_params
    return unless request.get? || request.head?

    params[:search] ||= ActionController::Parameters.new
    new_params = deep_reject_blank request.query_parameters

    redirect_to url_for(params: new_params) if new_params != request.query_parameters
  end

  def with_time_zone(&)
    # TODO: timezone cookie
    Time.use_zone("Berlin", &)
  end

  EXCEPTION_TYPES = {
    ActionController::BadRequest => 400,
    ActionController::ParameterMissing => 400,
    ActionController::InvalidAuthenticityToken => 403,
    ActionController::UnpermittedParameters => 403,
    ActiveRecord::RecordNotFound => 404,
    ActionController::UnknownFormat => 406,
    ActionView::MissingTemplate => 500,
    ActionView::Template::Error => 500,
    ActiveRecord::QueryCanceled => 500,
    PG::ConnectionBad => 503,
  }.freeze

  def rescue_exception(exception)
    @exception = exception

    @params = {
      params: request.filtered_parameters.except(:authenticity_token),
      referrer: request.referer,
      user_agent: request.user_agent,
    }

    console
    render "application/error", status: EXCEPTION_TYPES[exception.class] || 500
  end

  private

  def deep_reject_blank(hash)
    hash.transform_values do |v|
      if v.blank?
        nil
      elsif v.is_a?(Array)
        compact_array = v.compact_blank
        compact_array.empty? ? nil : compact_array
      elsif v.is_a?(Hash)
        deep_reject_blank v
      else
        v
      end
    end.compact
  end
end
