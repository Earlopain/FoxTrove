class UpdateMatchingE6PostsJob < ConcurrencyControlledJob
  good_job_control_concurrency_with(total_limit: 1, key: -> { arguments.first.to_s })

  def perform(search_params)
    SubmissionFile.search(search_params).find_each(&:update_e6_posts)
  end
end
