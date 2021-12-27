module ApplicationHelper
  def error_messages_for(value)
    value.errors.full_messagess.join(",")
  end

  def time_ago(value)
    tag.div value.to_formatted_s(:long), datetime: value.to_formatted_s(:iso8601), class: "time-ago"
  end
end
