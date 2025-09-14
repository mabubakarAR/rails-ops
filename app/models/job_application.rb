class JobApplication < ApplicationRecord
  belongs_to :job
  belongs_to :job_seeker

  validates :cover_letter, length: { maximum: 2000 }, allow_blank: true
  validates :status, presence: true
  validates :job_seeker_id, uniqueness: { scope: :job_id, message: "has already applied for this job" }

  enum status: {
    pending: 'pending',
    reviewed: 'reviewed',
    shortlisted: 'shortlisted',
    interviewed: 'interviewed',
    accepted: 'accepted',
    rejected: 'rejected',
    withdrawn: 'withdrawn'
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_job, ->(job_id) { where(job_id: job_id) }
  scope :by_job_seeker, ->(job_seeker_id) { where(job_seeker_id: job_seeker_id) }

  after_create :send_notification_to_company
  after_update :send_status_notification

  def days_since_applied
    (Date.current - applied_at.to_date).to_i
  end

  def is_recent_application?
    days_since_applied <= 3
  end

  def can_withdraw?
    %w[pending reviewed shortlisted].include?(status)
  end

  def can_update_status?(new_status)
    return false if withdrawn?
    return false if accepted? && new_status != 'accepted'
    return false if rejected? && new_status != 'rejected'
    true
  end

  private

  def send_notification_to_company
    JobApplicationNotificationJob.perform_later(self, 'new_application')
  end

  def send_status_notification
    return unless saved_change_to_status?
    JobApplicationNotificationJob.perform_later(self, 'status_update')
  end
end
