# frozen_string_literal: true

require "test_helper"

module Archives
  class ManualTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "it imports" do
      zip = Zip::OutputStream.write_buffer do |output|
        output.put_next_entry("file1.jpg")
        output.write file_fixture("1.jpg").read

        output.put_next_entry("invalid_file.jpg")
        output.write "abc"
      end

      Zip::File.stubs(:open).with(zip).yields(Zip::File.open_buffer(zip))
      archive = Archives.detect(zip)
      assert_instance_of(Archives::Manual, archive)

      archive.import(create(:artist).id, "https://manual.com")
      assert_enqueued_jobs 1, only: ArchiveBlobImportJob
      assert_equal(["invalid_file.jpg isn't a valid file"], archive.failed_imports)
    end
  end
end
