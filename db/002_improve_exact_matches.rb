#!/usr/bin/env ruby
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), "..", "config", "environment"))

E6IqdbData
  .includes(:submission_file)
  .select(:id)
  .distinct
  .joins(
    :submission_file,
    "inner join submission_files sf2 on sf2.iqdb_hash = submission_files.iqdb_hash",
    "inner join e6_iqdb_data eid2 on eid2.submission_file_id = sf2.id",
  )
  .where(is_exact_match: false)
  .where(eid2: { is_exact_match: true })
  .where("e6_iqdb_data.post_id = eid2.post_id")
  .update_all(is_exact_match: true) # rubocop:disable Rails/SkipsModelValidations
