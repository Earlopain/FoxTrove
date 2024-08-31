module NavHelper
  def nav_link_to(text, url, **)
    link = link_to(text, url, class: nav_link_class(url), **)
    tag.li(link)
  end

  def subnav_link_to(text, url, **)
    link = link_to(text, url, **)
    tag.li(link)
  end

  def secondary_links_exist?
    lookup_context.template_exists?("secondary_links", controller_name, true)
  end

  def nav_link_class(url)
    return "current" if url == "/#{params[:controller]}" || url.start_with?("/#{params[:controller]}/")

    "current" if url == "/" && request.path == "/"
  end
end
