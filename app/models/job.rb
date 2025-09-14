class Job < ApplicationRecord
  belongs_to :company
  has_many :job_applications, dependent: :destroy
  has_many :job_seekers, through: :job_applications
  has_many :job_categories, dependent: :destroy
  has_many :categories, through: :job_categories

  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 5000 }
  validates :requirements, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :location, presence: true
  validates :employment_type, presence: true
  validates :salary_min, numericality: { greater_than: 0 }, allow_blank: true
  validates :salary_max, numericality: { greater_than: 0 }, allow_blank: true
  validates :status, presence: true

  enum employment_type: {
    full_time: 'full_time',
    part_time: 'part_time',
    contract: 'contract',
    freelance: 'freelance',
    internship: 'internship'
  }

  enum status: {
    draft: 'draft',
    active: 'active',
    paused: 'paused',
    closed: 'closed'
  }

  scope :active, -> { where(status: 'active') }
  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  scope :by_employment_type, ->(type) { where(employment_type: type) }
  scope :by_salary_range, ->(min, max) { where(salary_min: min..max) }
  scope :remote, -> { where(remote: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_company, ->(company_id) { where(company_id: company_id) }

  def total_applications
    job_applications.count
  end

  def pending_applications
    job_applications.where(status: 'pending').count
  end

  def salary_range
    return nil if salary_min.blank? && salary_max.blank?
    return "#{salary_min}" if salary_max.blank?
    return "Up to #{salary_max}" if salary_min.blank?
    "#{salary_min} - #{salary_max}"
  end

  def days_since_posted
    (Date.current - created_at.to_date).to_i
  end

  def is_recent?
    days_since_posted <= 7
  end

  def application_deadline_passed?
    return false unless application_deadline.present?
    Date.current > application_deadline
  end

  def can_apply?(job_seeker)
    return false unless active?
    return false if application_deadline_passed?
    !job_applications.exists?(job_seeker: job_seeker)
  end
end
