# frozen_string_literal: true

module Archives
  class Base
    attr_accessor :imported_files, :already_imported_count, :failed_imports, :error

    def initialize(file)
      @file = file
      @imported_files = {}
      @already_imported_count = 0
      @failed_imports = []
      @error = nil
    end

    def import(artist_id, source_url)
      import_submission_files(artist_id, source_url)
    rescue Zip::Error => e
      @error = e
    end

    def import_file(artist_submission, entry)
      if artist_submission.submission_files.exists?(file_identifier: entry.name)
        @already_imported_count += 1
      else
        bin_file = Tempfile.new(binmode: true)
        bin_file.write(entry.get_input_stream.read)
        bin_file.rewind

        blob = SubmissionFile.blob_for_io(bin_file, File.basename(entry.name))
        if !blob || blob&.content_type == "application/octet-stream"
          @failed_imports.push("#{entry.name} isn't a valid file")
        else
          ArchiveBlobImportJob.perform_later(blob, artist_submission, entry.name)

          @imported_files[artist_submission.artist_url.id] ||= 0
          @imported_files[artist_submission.artist_url.id] += 1
        end
      end
    end

    def total_imported_files_count
      @imported_files.values.sum
    end

    protected

    def import_submission_files
      raise NotImplementedError
    end
  end
end
