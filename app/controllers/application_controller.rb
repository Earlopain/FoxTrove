# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_forgery_protection
  before_action :set_start_time
  before_action :normalize_params
  around_action :with_time_zone

  EXCEPTION_TYPES = {
    ActionController::BadRequest => 400,
    ActionController::ParameterMissing => 400,
    ActionController::InvalidAuthenticityToken => 403,
    ActionController::UnpermittedParameters => 403,
    ActiveRecord::RecordNotFound => 404,
    ActionController::UnknownFormat => 406,
    PG::ConnectionBad => 503,
  }.freeze
  exception_classes = Rails.env.test? ? EXCEPTION_TYPES.keys : Exception
  rescue_from(*exception_classes, with: :rescue_exception)

  def set_start_time
    @start_time = Time.current.to_f
  end

  def normalize_params
    return unless request.get? || request.head?

    new_params = deep_compact_blank(request.query_parameters)
    redirect_to url_for(params: new_params) if new_params != request.query_parameters
  end

  def with_time_zone(&)
    Time.use_zone(Config.time_zone, &)
  end

  def rescue_exception(exception)
    @exception = exception
    @exception = @exception.cause if @exception.is_a?(ActionView::Template::Error)

    @params = {
      params: request.filtered_parameters.except(:authenticity_token),
      referrer: request.referer,
      user_agent: request.user_agent,
    }
    status = EXCEPTION_TYPES[exception.class] || 500
    error_template = "application/error"
    error_template = "application/#{status}" if lookup_context.template_exists?(status, "application")

    render error_template, formats: [:html], status: status
  end

  def respond_with(value)
    if value.errors.any?
      # Always render new/edit, there are no specific templates for create/update
      render({ "create" => "new", "update" => "edit" }.fetch(action_name, action_name))
    else
      redirect_to(value)
    end
  end

  private

  def deep_compact_blank(hash)
    hash.transform_values do |v|
      if v.is_a?(Array)
        v.compact_blank
      elsif v.is_a?(Hash)
        deep_compact_blank v
      else
        v
      end
    end.compact_blank
  end
end
