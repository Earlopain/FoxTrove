class SessionLoader
def initialize(request)
    @request = request
    @session = request.session
  end

  def load
    CurrentUser.user = User.anon
    CurrentUser.ip_addr = @request.remote_ip

    return unless @session[:user_id] 

    user = User.find_by(id: @session[:user_id])
    if user
      CurrentUser.user = user
    else
      @session.delete(:user_id)
    end
  end
end
