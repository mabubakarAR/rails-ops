class JobSeeker < ApplicationRecord
  has_many :job_applications
  validates :name, :email, presence: true
end
