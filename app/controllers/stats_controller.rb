# frozen_string_literal: true

class StatsController < ApplicationController
  def index
    @original_size = sum_for("original", "SubmissionFile")
    @sample_size = sum_for("sample", "SubmissionFile")
    db_name = Rails.configuration.database_configuration[Rails.env]["database"]
    @db_size = ActiveRecord::Base.connection.execute("SELECT pg_database_size('#{db_name}');").first["pg_database_size"]
    @counts = SubmissionFile.select(
      :site_type,
      "count(distinct artist_id) as artist_count",
      "count(distinct artist_url_id) as url_count",
      "count(distinct artist_submission_id) as submission_count",
      "count(*) as file_count",
    ).joins(artist_submission: { artist_url: :artist }).group(:site_type).index_by(&:site_type)
    @counts.transform_keys! { |id| ArtistUrl.site_types.invert[id] }
    @definitions = Sites.definitions.sort_by(&:display_name)
  end

  def selenium
    render json: { active: SeleniumWrapper.active? }
  end

  private

  def sum_for(name, record_type)
    ActiveStorage::Blob.joins(:attachments).where(attachments: { name: name, record_type: record_type }).sum(:byte_size)
  end
end
