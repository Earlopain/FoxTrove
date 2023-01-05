# frozen_string_literal: true

module Archives
  # Archive Structure
  #
  # media
  # -----| reblog_post_id1.jpg
  # -----| reblog_post_id2_0.jpg
  # -----| reblog_post_id2_1.jpg
  # -----| reblog_post_id3.gif
  # posts.zip
  # -----| html
  # ----------| reblog_post_id1.html
  # ----------| reblog_post_id2.html
  # ----------| reblog_post_id3.html
  # -----| style.css
  # -----| posts_index.html
  class Tumblr < Base
    URL_ID_REGEX = %r{tumblr\.com/post/(?<id>\d*)}

    def self.handles_file(file)
      Zip::File.open(file) do |zip_file|
        zip_file.find_entry("posts.zip")
      end
    end

    protected

    def import_submission_files(_artist_id, _source_url)
      Zip::File.open(@file) do |zip_file|
        posts_zip_entry = zip_file.glob("posts.zip").first

        Zip::File.open_buffer(posts_zip_entry.get_input_stream.read) do |posts_zip|
          # For each reblogged post
          posts_zip.glob("html/*").each do |reblog_entry|
            import_reblog_entry(reblog_entry, zip_file)
          end
        end
      end
    end

    private

    def import_reblog_entry(reblog_entry, zip_file)
      html = Nokogiri::HTML(reblog_entry.get_input_stream)
      original_post_url = html.at(".tumblr_blog")
      reblog_post_id = File.basename(reblog_entry.name, ".html")
      media_files = zip_file.glob("media/#{reblog_post_id}*.*")

      if original_post_url.nil?
        @failed_imports.push("#{reblog_entry.name} No .tumblr_blog, #{media_files.count} files")
        return
      end

      original_post_id = URL_ID_REGEX.match(original_post_url["href"])[:id]
      submission = ArtistSubmission.for_site_with_identifier(site: "tumblr", identifier: original_post_id)
      if submission.nil?
        @failed_imports.push("#{reblog_entry.name} Submission #{original_post_id} not found")
        return
      end

      media_files.each do |media_file_entry|
        import_file(submission, media_file_entry)
      end
    end
  end
end
