# frozen_string_literal: true

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
    tag.span value.to_fs(:long), datetime: value.to_fs(:iso8601), class: "time-ago"
  end

  def link_to_external(text, url, **options)
    link_to text, url, **options, rel: "nofollow noopener noreferrer"
  end

  def fake_link(text, **params)
    tag.a(text, href: "#", **params, onclick: "return false;")
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

  def hideable_search(path, &)
    tag.div(class: "hideable-search-container", data: { form_visible: params[:search].present? }) do
      show = fake_link("Show Search Options", class: "hideable-search-show")
      hide = fake_link("Hide Search Options", class: "hideable-search-hide")
      form = simple_form_for(:search, method: :get, url: path, defaults: { required: false }, builder: HideableSearchFormBuilder, search_params: params[:search]) do |f|
        capture { yield(f) } + f.submit("Search")
      end
      show.concat(hide).concat(tag.span(form, class: "hideable-search-form"))
    end
  end

  def paginated(values)
    content_for(:paginator) { paginate values }
  end
end
