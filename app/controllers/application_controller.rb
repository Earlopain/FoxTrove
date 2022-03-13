class ApplicationController < ActionController::Base
  before_action :normalize_params
  around_action :with_time_zone

  helper_method :current_user

  rescue_from Exception, with: :rescue_exception

  def normalize_params
    return unless request.get?

    params[:search] ||= ActionController::Parameters.new
    deep_reject_blank = lambda do |hash|
      hash.transform_values do |v|
        if v.blank?
          nil
        elsif v.is_a?(Array)
          compact_array = v.compact_blank
          compact_array.empty? ? nil : compact_array
        elsif v.is_a?(Hash)
          deep_reject_blank.call v
        else
          v
        end
      end.compact
    end
    new_params = deep_reject_blank.call request.query_parameters

    redirect_to url_for(params: new_params) if new_params != request.query_parameters
  end

  def current_user
    @current_user ||= SessionLoader.new(request).load
  end

  def current_user_ip_addr
    request.remote_ip
  end

  def with_time_zone
    Time.use_zone(current_user.time_zone) { yield }
  end

  User.levels.each_key do |level|
    define_method("#{level}_only") do
      raise User::PrivilegeError unless current_user.send("#{level}?")
    end
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

    if @exception.is_a?(User::PrivilegeError) && current_user.anon?
      if request.get?
        redirect_to new_session_path(previous_url: request.fullpath)
      else
        redirect_to new_session_path
      end
      return
    end

    @params = {
      params: request.filtered_parameters.except(:authenticity_token),
      user_id: current_user.id,
      referrer: request.referer,
      user_agent: request.user_agent,
    }

    console
    render "static/error", status: EXCEPTION_TYPES[exception.class] || 500
  end
end
