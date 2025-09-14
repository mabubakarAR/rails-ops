class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 'admin', company: 'company', job_seeker: 'job_seeker' }

  has_one :company, dependent: :destroy
  has_one :job_seeker, dependent: :destroy

  validates :role, presence: true
  validates :email, presence: true, uniqueness: true

  def full_name
    if job_seeker?
      job_seeker&.full_name || email
    elsif company?
      company&.name || email
    else
      email
    end
  end

  def profile_complete?
    case role
    when 'company'
      company.present? && company.name.present?
    when 'job_seeker'
      job_seeker.present? && job_seeker.first_name.present? && job_seeker.last_name.present?
    else
      true
    end
  end
end
