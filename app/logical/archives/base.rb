# frozen_string_literal: true

module Archives
  class Base
    attr_accessor :imported_files, :skipped_count, :failed_imports, :error

    def initialize(file)
      @file = file
      @imported_files = {}
      @skipped_count = 0
      @failed_imports = []
      @error = nil
    end

    def import
      import_submission_files
    rescue Zip::Error => e
      @error = e
    end

    def import_file(submission, file, index)
      bin_file = Tempfile.new(binmode: true)
      bin_file.write(file.get_input_stream.read)
      bin_file.rewind
      SubmissionFile.from_file(
        file: bin_file,
        artist_submission_id: submission.id,
        url: "file:///#{file.name}",
        created_at: submission.created_at_on_site,
        file_identifier: index,
      )

      @imported_files[submission.artist_url.id] ||= 0
      @imported_files[submission.artist_url.id] += 1
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
