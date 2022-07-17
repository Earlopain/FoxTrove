# frozen_string_literal: true

class DropSidekiqJobId < ActiveRecord::Migration[7.0]
  def change
    remove_column :artist_urls, :sidekiq_job_id, :text, null: true
  end
end
