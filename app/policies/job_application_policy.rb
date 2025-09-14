class JobApplicationPolicy < ApplicationPolicy
  def index?
    user.admin? || user.company? || user.job_seeker?
  end

  def show?
    user.admin? || 
    (user.company? && record.job.company.user == user) ||
    (user.job_seeker? && record.job_seeker.user == user)
  end

  def create?
    user.job_seeker?
  end

  def update?
    user.admin? || 
    (user.company? && record.job.company.user == user) ||
    (user.job_seeker? && record.job_seeker.user == user && record.can_withdraw?)
  end

  def destroy?
    user.admin? || 
    (user.job_seeker? && record.job_seeker.user == user && record.can_withdraw?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.company?
        scope.joins(:job).where(jobs: { company: user.company })
      elsif user.job_seeker?
        scope.where(job_seeker: user.job_seeker)
      else
        scope.none
      end
    end
  end
end
