class SessionLoader
  def initialize(request)
    @request = request
    @session = request.session
  end

  def load
    CurrentUser.user = Account.anonymous
    CurrentUser.ip_addr = @request.remote_ip

    return unless @session[:account_id] 

    CurrentUser.user = Account.find_by(id: @session[:account_id])
  end
end
