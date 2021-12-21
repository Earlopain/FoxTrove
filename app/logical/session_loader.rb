class SessionLoader
  attr_reader :request, :session, :cookies

  def initialize(request)
    @request = request
    @session = request.session
    @cookies = request.cookie_jar
  end

  def load
    CurrentUser.user = User.anon
    CurrentUser.ip_addr = request.remote_ip

    user_id = fetch_user_id_and_refresh_remember_cookie
    return unless user_id

    user = User.find_by(id: user_id)
    if user
      CurrentUser.user = user
    else
      session.delete(:user_id)
      cookies.encrypted.delete(:remember_me)
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
