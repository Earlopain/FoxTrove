class Backlog < ApplicationRecord
  belongs_to :user
  belongs_to :submission_file
end
