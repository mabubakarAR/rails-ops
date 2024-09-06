class Job < ApplicationRecord
  belongs_to :company
  has_many :job_applications
  validates :title, :description, :location, :salary, presence: true
end
