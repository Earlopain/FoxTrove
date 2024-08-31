class PurgeUnattachedBlobsJob < ApplicationJob
  def perform
    ActiveStorage::Blob.unattached.where(created_at: ..2.days.ago).find_each(&:purge)
  end
end
