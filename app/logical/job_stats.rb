class JobStats
  def active_urls
    (e6_iqdb_queued.keys + submission_download_queued.keys + scraping_queued.keys + scraping_now).uniq
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
    @scraping_now ||= GoodJob::JobsFilter.new(state: "running", queue_name: "scraping").records.map { |job| extract_model_id(job) }
  end

  private

  def extract_model_id(job)
    first_argument = job.serialized_params["arguments"][0]
    URI::GID.parse(first_argument["_aj_globalid"]).model_id.to_i
  end

  def stats_queued(queue_name, count_proc)
    result = {}
    query = GoodJob::JobsFilter.new(queue_name: queue_name).filtered_query
    query = query.merge(GoodJob::Job.queued.or(GoodJob::Job.retried).or(GoodJob::Job.scheduled))
    query.find_in_batches(batch_size: 1000) do |batch|
      ids = batch.map { |job| extract_model_id(job) }
      db_count = count_proc.call(ids)
      result = result.merge(db_count) { |_k, old_v, new_v| old_v + new_v }
    end
    result
  end
end
