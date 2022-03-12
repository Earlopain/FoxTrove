class SubmissionFileSetNonNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :submission_files, :width, false
    change_column_null :submission_files, :height, false
    change_column_null :submission_files, :size, false
    change_column_null :submission_files, :content_type, false
  end
end
