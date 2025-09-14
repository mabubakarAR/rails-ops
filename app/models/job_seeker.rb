class JobSeeker < ApplicationRecord
  belongs_to :user
  has_many :job_applications, dependent: :destroy
  has_many :jobs, through: :job_applications
  has_many :job_seeker_skills, dependent: :destroy
  has_many :skills, through: :job_seeker_skills

  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :location, presence: true
  validates :bio, length: { maximum: 1000 }, allow_blank: true
  validates :experience_years, numericality: { greater_than_or_equal_to: 0, less_than: 100 }, allow_blank: true

  scope :by_location, ->(location) { where("location ILIKE ?", "%#{location}%") }
  scope :by_experience, ->(min_years) { where("experience_years >= ?", min_years) }
  scope :with_skills, ->(skill_ids) { joins(:skills).where(skills: { id: skill_ids }).distinct }

  def full_name
    "#{first_name} #{last_name}"
  end

  def total_applications
    job_applications.count
  end

  def pending_applications
    job_applications.where(status: 'pending').count
  end

  def accepted_applications
    job_applications.where(status: 'accepted').count
  end

  def rejected_applications
    job_applications.where(status: 'rejected').count
  end

  def skill_names
    skills.pluck(:name)
  end

  def profile_completion_percentage
    required_fields = %w[first_name last_name location bio]
    completed_fields = required_fields.count { |field| send(field).present? }
    (completed_fields.to_f / required_fields.count * 100).round
  end
end
