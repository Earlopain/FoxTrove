module NavHelper
  def nav_link_to(text, url)
    render "application/primary_link", text: text, url: url
  end

  def subnav_link_to(text, url)
    render "application/secondary_link", text: text, url: url
  end

  def nav_link_class(url)
    return "current" if url.start_with? "/#{params[:controller]}"
    return "current" if url == "/" && request.path == "/"

    ""
  end
end
