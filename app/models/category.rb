class Category < ApplicationRecord
  has_many :skills, dependent: :destroy
  has_many :job_categories, dependent: :destroy
  has_many :jobs, through: :job_categories

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
  validates :description, length: { maximum: 500 }, allow_blank: true

  scope :popular, -> { joins(:jobs).group('categories.id').order('COUNT(jobs.id) DESC') }
  scope :with_jobs, -> { joins(:jobs).distinct }

  def job_count
    jobs.count
  end

  def active_job_count
    jobs.active.count
  end
end
