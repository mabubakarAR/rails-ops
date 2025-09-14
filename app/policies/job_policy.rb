class JobPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.company? || user.admin?
  end

  def update?
    user.admin? || (user.company? && record.company.user == user)
  end

  def destroy?
    user.admin? || (user.company? && record.company.user == user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.company?
        scope.where(company: user.company)
      else
        scope.active
      end
    end
  end
end
