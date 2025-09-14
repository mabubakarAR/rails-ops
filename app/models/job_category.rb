class JobCategory < ApplicationRecord
  belongs_to :job
  belongs_to :category

  validates :job_id, uniqueness: { scope: :category_id }
end
