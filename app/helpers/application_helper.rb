module ApplicationHelper
  def error_messages_for(value)
    value.errors.full_messagess.join(",")
  end
end
