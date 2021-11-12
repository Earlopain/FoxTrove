class SessionsController < ApplicationController
  def create
    account = Account.find_by(username: params[:username])
    if account&.authenticate params[:password]
      session[:account_id] = account.id
      redirect_to(root_path, notice: "Logged in as #{account.username}")
    else
      redirect_to(root_path, notice: "Username/Password was incorrect")
    end
  end

  def destroy
    session.delete(:account_id)
    redirect_to(root_path, :notice => "Logged out")
  end
end
