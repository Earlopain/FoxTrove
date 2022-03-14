class SessionLoader
  attr_reader :request, :session, :cookies

  def initialize(request)
    @request = request
    @session = request.session
    @cookies = request.cookie_jar
  end

  def load
    user_id = fetch_user_id_and_refresh_remember_cookie

    user = User.find_by(id: user_id)
    if user
      user.update_attribute(:last_logged_in_at, Time.zone.now) if user.last_logged_in_at > 1.day.ago
      user
    else
      session.delete(:user_id)
      cookies.delete(:remember_me)
      User.anon
    end
  end

  private

  def fetch_user_id_and_refresh_remember_cookie
    # The cookie needs to come first as it wouldn't be updated otherwise
    if cookies.encrypted[:remember_me]
      cookies.encrypted[:remember_me] = { value: cookies.encrypted[:remember_me], expires: 2.weeks.from_now, httponly: true }
      cookies.encrypted[:remember_me]
    elsif session[:user_id]
      session[:user_id]
    end
  end
end
