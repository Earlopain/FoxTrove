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

    def import
      import_submission_files
    rescue Zip::Error => e
      @error = e
    end

    def import_file(artist_submission, file, index)
      if artist_submission.submission_files.exists?(file_identifier: index)
        @already_imported_count += 1
      else
        bin_file = Tempfile.new(binmode: true)
        bin_file.write(file.get_input_stream.read)
        bin_file.rewind
        SubmissionFile.from_file(
          file: bin_file,
          artist_submission_id: artist_submission.id,
          url: "file:///#{file.name}",
          created_at: artist_submission.created_at_on_site,
          file_identifier: index,
        )
        @imported_files[artist_submission.artist_url.id] ||= 0
        @imported_files[artist_submission.artist_url.id] += 1
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
