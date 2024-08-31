class E6Post < ApplicationRecord
  belongs_to :submission_file

  def direct_url
    post_json["file"]["url"]
  end

  def score
    post_json["score"]["total"]
  end
end
