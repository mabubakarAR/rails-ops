class Skill < ApplicationRecord
  belongs_to :category
  has_many :job_seeker_skills, dependent: :destroy
  has_many :job_seekers, through: :job_seeker_skills

  validates :name, presence: true, uniqueness: { scope: :category_id }, length: { minimum: 2, maximum: 50 }

  scope :popular, -> { joins(:job_seeker_skills).group('skills.id').order('COUNT(job_seeker_skills.id) DESC') }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def job_seeker_count
    job_seekers.count
  end

  def self.search(query)
    where("name ILIKE ?", "%#{query}%")
  end
end
