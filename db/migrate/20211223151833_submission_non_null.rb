# frozen_string_literal: true

class SubmissionNonNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :artist_submissions, :title_on_site, false
    change_column_null :artist_submissions, :description_on_site, false

    drop_table :sites
  end
end
