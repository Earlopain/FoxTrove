class E6Post < ApplicationRecord
  belongs_to :submission_file

  def direct_url
    post_json.dig("files", "original", "url")
  end

  def score
    post_json.dig("stats", "score", "total")
  end
end
