module NavHelper
  def nav_link_to(text, url)
    render "application/primary_link", text: text, url: url
  end

  def subnav_link_to(text, url)
    render "application/secondary_link", text: text, url: url
  end

  def nav_link_class(url)
    regex = case params[:controller]
            when "iqdb"
              %r{^/iqdb}
            end
    regex&.match?(url) ? "current" : ""
  end
end
