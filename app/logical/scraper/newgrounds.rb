module Scraper
  class Newgrounds < Base
    def init
      @page = 1
      @submission_cache = []
      @will_have_more = true
    end

    def enabled?
      true
    end

    def fetch_next_batch
      # Newgrounds has no api, searching basically only returns the url, nothing more.
      # Loading all html pages just to see if something new is bad, so it's buffered here, so that
      # it can be checked on each submission one after the other
      if @submission_cache.empty?
        response = get_from_page(@page)
        submissions = response["sequence"].map { |year| response["years"][year.to_s]["items"] }.flatten
        @submission_cache = submissions.map { |entry| Nokogiri::HTML(entry).css("a").first.attributes["href"].value }
        @page += 1
        @will_have_more = response["more"].present?
      end

      single_submission_url = @submission_cache.shift
      end_reached if @submission_cache.empty? && !@will_have_more
      [get_submission_details(single_submission_url)]
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission[:identifier]
      s.title = submission[:title]
      s.description = submission[:description]
      created_at = extract_timestamp submission
      s.created_at = created_at

      submission[:files].each_with_index do |url, index|
        s.add_file({
          url: url,
          created_at: created_at,
          identifier: index,
        })
      end
      s
    end

    def extract_timestamp(submission)
      submission[:created_at]
    end

    private

    def get_from_page(page)
      url = "https://#{@identifier}.newgrounds.com/art/page/#{page}"
      response = HTTParty.get(url, headers: {
        "X-Requested-With": "XMLHttpRequest",
      })
      JSON.parse(response.body)
    end

    def get_submission_details(url)
      response = HTTParty.get(url)
      html = Nokogiri::HTML(response.body)
      media_object = html.at("[itemtype='https://schema.org/MediaObject']")
      main_image_url = media_object.at(".image img").attributes["src"].value
      secondary_image_urls = media_object.css("#author_comments img[data-smartload-src]").map { |e| e.attributes["data-smartload-src"].value }
      {
        identifier: url.split("/").pop,
        title: media_object.at("[itemprop='name']").content.strip,
        description: media_object.at("#author_comments")&.content&.strip || "",
        created_at: DateTime.parse(media_object.at("[itemprop='datePublished']").attributes["content"].value),
        files: [main_image_url] + secondary_image_urls,
      }
    end
  end
end
