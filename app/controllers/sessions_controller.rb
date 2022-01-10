class SessionsController < ApplicationController
  def new
    redirect_to(root_path, notice: "You are already logged in") unless CurrentUser.is_anon?
  end

  def create
    user = User.find_by(name: params[:username])
    if user&.authenticate params[:password]
      session[:user_id] = user.id
      cookies.encrypted[:remember_me] = { value: user.id, expires: 2.weeks.from_now, httponly: true } if params[:remember_me]

      redirect_to(params[:previous_url] || root_path, notice: "Logged in as #{user.name}")
    else
      redirect_to(new_session_path(previous_url: params[:previous_url]), notice: "Username/Password was incorrect")
    end
  end

  def destroy
    session.delete(:user_id)
    cookies.delete(:remember_me)
    redirect_to(root_path, notice: "Logged out")
  end
end
