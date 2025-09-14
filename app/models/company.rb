class Company < ApplicationRecord
  belongs_to :user
  has_many :jobs, dependent: :destroy
  has_many :job_applications, through: :jobs

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :website, format: { with: URI::regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :industry, presence: true
  validates :size, presence: true
  validates :founded_year, numericality: { greater_than: 1800, less_than_or_equal_to: Date.current.year }, allow_blank: true

  enum :size, {
    startup: 'startup',
    small: 'small',
    medium: 'medium',
    large: 'large',
    enterprise: 'enterprise'
  }

  scope :active, -> { joins(:user).where(users: { role: 'company' }) }
  scope :by_industry, ->(industry) { where(industry: industry) }
  scope :by_size, ->(size) { where(size: size) }

  def total_jobs
    jobs.count
  end

  def active_jobs
    jobs.where(status: 'active').count
  end

  def total_applications
    job_applications.count
  end

  def average_rating
    # This would be implemented when we add rating system
    0
  end
end
