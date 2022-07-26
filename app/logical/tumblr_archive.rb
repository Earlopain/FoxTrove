# frozen_string_literal: true

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
class TumblrArchive
  attr_accessor :imported_files_count, :skipped_count, :failed_imports, :error

  URL_ID_REGEX = %r{tumblr\.com/post/(?<id>\d*)}

  def initialize(file)
    @file = file
    @imported_files_count = 0
    @skipped_count = 0
    @failed_imports = []
    @error = nil
  end

  def import_submission_files
    Zip::File.open(@file) do |zip_file|
      posts_zip_entry = zip_file.glob("posts.zip").first

      Zip::File.open_buffer(posts_zip_entry.get_input_stream.read) do |posts_zip|
        # For each reblogged post
        posts_zip.glob("html/*").each do |reblog_entry|
          import_reblog_entry(reblog_entry, zip_file)
        end
      end
    end
  rescue Zip::Error => e
    @error = e
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
    elsif submission.submission_files.any?
      @skipped_count += media_files.count
      return
    end

    media_files.each.with_index do |file, index|
      bin_file = Tempfile.new(binmode: true)
      bin_file.write(file.get_input_stream.read)
      bin_file.rewind
      SubmissionFile.from_bin_file(bin_file, artist_submission_id: submission.id,
                                             url: "file:///#{file.name}",
                                             created_at: submission.created_at_on_site,
                                             file_identifier: index)

      @imported_files_count += 1
    end
  end
end
