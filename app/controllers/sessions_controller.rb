class SessionsController < ApplicationController
  def create
    user = User.find_by(name: params[:username])
    if user&.authenticate params[:password]
      session[:user_id] = user.id
      redirect_to(root_path, notice: "Logged in as #{user.name}")
    else
      redirect_to(root_path, notice: "Username/Password was incorrect")
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to(root_path, :notice => "Logged out")
  end
end
