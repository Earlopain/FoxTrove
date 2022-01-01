class ApplicationController < ActionController::Base
  before_action :set_current_user
  around_action :with_time_zone

  rescue_from Exception, with: :rescue_exception

  def set_current_user
    CurrentUser.user = SessionLoader.new(request).load
    CurrentUser.ip_addr = request.remote_ip
  end

  def with_time_zone
    Time.use_zone(CurrentUser.time_zone) { yield }
  end

  User::Levels.ordered.each do |level|
    define_method("#{level.downcase}_only") do
      raise User::PrivilegeError unless CurrentUser.user.send("is_#{level}?")
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

    if @exception.is_a?(User::PrivilegeError) && CurrentUser.is_anon?
      redirect_to new_session_path(previous_url: request.fullpath)
      return
    end

    @params = {
      params: request.filtered_parameters.except(:authenticity_token),
      user_id: CurrentUser.id,
      referrer: request.referer,
      user_agent: request.user_agent,
    }

    console
    render "static/error", status: EXCEPTION_TYPES[exception.class] || 500
  end
end
