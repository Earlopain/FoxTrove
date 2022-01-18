class StatsController < ApplicationController
  def index
    @artist_urls = ArtistUrl.where id: SidekiqStats.active_urls
    @original_size = sum_for("original", "SubmissionFile")
    @sample_size = sum_for("sample", "SubmissionFile")
  end

  private

  def sum_for(name, record_type)
    ActiveStorage::Blob.joins(:attachments).where(attachments: { name: , record_type: }).sum(:byte_size)
  end
end
