# frozen_string_literal: true

module SidekiqStats
  def self.active_urls
    e6_iqdb_queued.keys + submission_download_queued.keys + scraping_queued.keys + scraping_now
  end

  def self.e6_iqdb_queued
    proc = ->(ids) { ArtistUrl.joins(submissions: :submission_files).where(submissions: { submission_files: { id: ids } }).group(:id).count }
    stats_queued("e6_iqdb", proc)
  end

  def self.submission_download_queued
    proc = ->(ids) { ArtistUrl.joins(:submissions).where(submissions: { id: ids }).group(:id).count }
    stats_queued("submission_download", proc)
  end

  def self.scraping_queued
    proc = ->(ids) { ArtistUrl.where(id: ids).group(:id).count }
    stats_queued("scraping", proc)
  end

  def self.scraping_now
    Sidekiq::Workers.new.filter_map do |_process_id, _thread_id, work|
      work["payload"]["args"][0] if work["queue"] == "scraping" && work["payload"]["class"] == "ScrapeArtistUrlWorker"
    end
  end

  def self.stats_queued(queue, count_proc)
    Cache.fetch("#{queue}_stats", 1.minute) do
      queue = Sidekiq::Queue.new(queue)
      result = Hash.new(0)
      queue.each_slice(1000) do |batch|
        ids = batch.map { |job| job.args[0] }
        count_db = count_proc.call(ids)
        count_db.each do |artist_url_id, count|
          result[artist_url_id] += count
        end
      end
      result.default = nil
      result
    end
  end
end
