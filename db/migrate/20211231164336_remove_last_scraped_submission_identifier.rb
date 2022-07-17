# frozen_string_literal: true

class RemoveLastScrapedSubmissionIdentifier < ActiveRecord::Migration[7.0]
  def change
    remove_column :artist_urls, :last_scraped_submission_identifier, :text
  end
end
