# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

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

  def link_to_external(text, url, **)
    link_to text, url, **, rel: "nofollow noopener noreferrer"
  end

  def fake_link(text, **)
    tag.a(text, href: "#", **, onclick: "return false;")
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

  def toggleable(id, show_text, hide_text, visible_on_load:, &block)
    tag.span(class: "toggleable-container", id: id, data: { content_visible: visible_on_load }) do
      show = fake_link(show_text, class: "link-show")
      hide = fake_link(hide_text, class: "link-hide")
      toggleable_content = block ? capture(&block) : ""
      show.concat(hide).concat(tag.span(toggleable_content, class: "toggleable-content"))
    end
  end

  def hideable_search(path, &)
    search = toggleable("search", "Show Search Options", "Hide Search Options", visible_on_load: params[:search].present?) do
      simple_form_for(:search, method: :get, url: path, defaults: { required: false }, builder: HideableSearchFormBuilder, search_params: params[:search]) do |f|
        capture { yield(f) } + f.submit("Search")
      end
    end
    tag.div(search)
  end

  def job_stats
    @job_stats ||= JobStats.new
  end
end
