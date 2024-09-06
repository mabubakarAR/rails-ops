class JobApplication < ApplicationRecord
  belongs_to :job
  belongs_to :job_seeker
  validates :status, inclusion: { in: %w[pending accepted rejected] }
end
