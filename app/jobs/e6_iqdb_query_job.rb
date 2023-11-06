# frozen_string_literal: true

class E6IqdbQueryJob < ApplicationJob
  queue_as :e6_iqdb

  PRIORITIES = {
    immediate: 100,
    manual_action: 10,
    automatic_action: 0,
  }.freeze

  def perform(submission_file)
    submission_file.update_e6_posts!
  end
end
