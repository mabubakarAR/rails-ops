class JobSeekerSkill < ApplicationRecord
  belongs_to :job_seeker
  belongs_to :skill

  validates :job_seeker_id, uniqueness: { scope: :skill_id }
  validates :proficiency_level, presence: true, inclusion: { in: %w[beginner intermediate advanced expert] }

  enum proficiency_level: {
    beginner: 'beginner',
    intermediate: 'intermediate',
    advanced: 'advanced',
    expert: 'expert'
  }
end
