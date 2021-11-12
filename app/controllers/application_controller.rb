class ApplicationController < ActionController::Base
  before_action :set_current_user

  def set_current_user
    SessionLoader.new(request).load
  end
end
