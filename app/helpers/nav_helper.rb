# frozen_string_literal: true

module NavHelper
  def nav_link_to(text, url, **options)
    render "application/primary_link", text: text, url: url, options: options
  end

  def subnav_link_to(text, url, **options)
    render "application/secondary_link", text: text, url: url, options: options
  end

  def nav_link_class(url)
    return "current" if url.start_with?("/#{params[:controller]}") || url.start_with?("/#{params[:controller].singularize}")
    return "current" if url == "/" && request.path == "/"

    ""
  end
end
