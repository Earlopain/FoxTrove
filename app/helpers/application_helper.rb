module ApplicationHelper
  def error_messages_for(value)
    value.errors.full_messagess.join(",")
  end

  # The original doesn't seem to handle negatives at all
  # -312153 => "-312153 Bytes"
  def number_to_human_size(number, **options)
    original_result = super(number.abs, **options)
    "#{number < 0 ? '-' : ''}#{original_result}"
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

  def link_to_external(text, url, **options)
    link_to text, url, **options, rel: "nofollow noopener noreferrer"
  end

  def page_title(title = nil)
    if title.present?
      content_for(:page_title) { title }
    elsif content_for? :page_title
      "#{content_for(:page_title)} - #{Config.app_name}"
    else
      Config.app_name
    end
  end

  def hideable_search(path, &block)
    tag.div(id: "hideable-search-container") do
      show = tag.div("Show Search Options", href: "#", id: "hideable-search-show", class: "link #{'hidden' if params[:search].present?}")
      hide = tag.div("Hide Search Options", href: "#", id: "hideable-search-hide", class: "link #{'hidden' if params[:search].blank?}")
      form = simple_form_for(:search, method: :get, url: path, defaults: { required: false }, &block)
      show.concat(hide).concat(tag.span(form, id: "hideable-search-form", class: ("hidden" if params[:search].blank?)))
    end
  end
end
