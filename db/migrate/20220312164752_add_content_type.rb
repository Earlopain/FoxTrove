class AddContentType < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :content_type, :text

    SubmissionFile.where(content_type: nil).find_each do |submission_file|
      submission_file.update(:content_type, submission_file.original.content_type)
    end
  end
end
