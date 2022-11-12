# frozen_string_literal: true

class JobStats
  def active_urls
    e6_iqdb_queued.keys + submission_download_queued.keys + scraping_queued.keys + scraping_now
  end

  def e6_iqdb_queued
    proc = ->(ids) { ArtistUrl.joins(submissions: :submission_files).where(submissions: { submission_files: { id: ids } }).group(:id).count }
    @e6_iqdb_queued ||= stats_queued("e6_iqdb", proc)
  end

  def submission_download_queued
    proc = ->(ids) { ArtistUrl.joins(:submissions).where(submissions: { id: ids }).group(:id).count }
    @submission_download_queued ||= stats_queued("submission_download", proc)
  end

  def scraping_queued
    proc = ->(ids) { ArtistUrl.where(id: ids).group(:id).count }
    @scraping_queued ||= stats_queued("scraping", proc)
  end

  def scraping_now
    @scraping_now ||= GoodJob::JobsFilter.new(state: "running", queue_name: "scraping").records.map do |job|
      job.serialized_params["arguments"][0]
    end
  end

  private

  def stats_queued(queue_name, count_proc)
    result = Hash.new(0)
    queue = GoodJob::JobsFilter.new(state: "queued", queue_name: queue_name).filtered_query
    queue.each_slice(1000) do |batch|
      ids = batch.map { |job| job.serialized_params["arguments"][0] }
      count_db = count_proc.call(ids)
      count_db.each do |artist_url_id, count|
        result[artist_url_id] += count
      end
    end
    result.default = nil
    result
  end
end
