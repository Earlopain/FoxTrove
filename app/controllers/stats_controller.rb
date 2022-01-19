class StatsController < ApplicationController
  def index
    @artist_urls = ArtistUrl.where id: SidekiqStats.active_urls
    @original_size = sum_for("original", "SubmissionFile")
    @sample_size = sum_for("sample", "SubmissionFile")
    db_name = Rails.configuration.database_configuration[Rails.env]["database"]
    @db_size = ActiveRecord::Base.connection.execute("SELECT pg_database_size('#{db_name}');").first["pg_database_size"]
  end

  private

  def sum_for(name, record_type)
    ActiveStorage::Blob.joins(:attachments).where(attachments: { name: , record_type: }).sum(:byte_size)
  end
end
