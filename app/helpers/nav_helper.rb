# frozen_string_literal: true

module NavHelper
  def nav_link_to(text, url, **options)
    link = link_to(text, url, class: nav_link_class(url), **options)
    tag.li(link)
  end

  def subnav_link_to(text, url, **options)
    link = link_to(text, url, **options)
    tag.li(link)
  end

  def nav_link_class(url)
    return "current" if url.start_with?("/#{params[:controller]}") || url.start_with?("/#{params[:controller].singularize}")
    return "current" if url == "/" && request.path == "/"
  end
end
