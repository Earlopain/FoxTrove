module ApplicationHelper
  def error_messages_for(value)
    value.errors.full_messagess.join(",")
  end

  def time_ago(value)
    tag.span value.to_formatted_s(:long), datetime: value.to_formatted_s(:iso8601), class: "time-ago"
  end

  def site_icon(artist_url, text: nil, link_target: nil, **options)
    icon = tag.span(class: artist_url.site.icon_class)
    icon.concat tag.span(text, class: "site-icon-text") if text

    return tag.span(icon, **options) unless link_target

    link_to tag.span(icon), link_target, options
  end
end
