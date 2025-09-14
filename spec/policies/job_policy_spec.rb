require 'rails_helper'

RSpec.describe JobPolicy, type: :policy do
  let(:admin_user) { create(:user, :admin) }
  let(:company_user) { create(:user, :company) }
  let(:company) { create(:company, user: company_user) }
  let(:other_company_user) { create(:user, :company) }
  let(:other_company) { create(:company, user: other_company_user) }
  let(:job_seeker_user) { create(:user, :job_seeker) }
  let(:job) { create(:job, company: company) }
  let(:other_job) { create(:job, company: other_company) }

  subject { described_class }

  permissions :index? do
    it 'allows all users to view jobs' do
      expect(subject).to permit(admin_user, Job)
      expect(subject).to permit(company_user, Job)
      expect(subject).to permit(job_seeker_user, Job)
    end
  end

  permissions :show? do
    it 'allows all users to view individual jobs' do
      expect(subject).to permit(admin_user, job)
      expect(subject).to permit(company_user, job)
      expect(subject).to permit(job_seeker_user, job)
    end
  end

  permissions :create? do
    it 'allows company users and admins to create jobs' do
      expect(subject).to permit(admin_user, Job)
      expect(subject).to permit(company_user, Job)
    end

    it 'denies job seekers from creating jobs' do
      expect(subject).not_to permit(job_seeker_user, Job)
    end
  end

  permissions :update? do
    it 'allows admin to update any job' do
      expect(subject).to permit(admin_user, job)
      expect(subject).to permit(admin_user, other_job)
    end

    it 'allows company user to update own jobs' do
      expect(subject).to permit(company_user, job)
    end

    it 'denies company user from updating other companies jobs' do
      expect(subject).not_to permit(company_user, other_job)
    end

    it 'denies job seekers from updating jobs' do
      expect(subject).not_to permit(job_seeker_user, job)
    end
  end

  permissions :destroy? do
    it 'allows admin to destroy any job' do
      expect(subject).to permit(admin_user, job)
      expect(subject).to permit(admin_user, other_job)
    end

    it 'allows company user to destroy own jobs' do
      expect(subject).to permit(company_user, job)
    end

    it 'denies company user from destroying other companies jobs' do
      expect(subject).not_to permit(company_user, other_job)
    end

    it 'denies job seekers from destroying jobs' do
      expect(subject).not_to permit(job_seeker_user, job)
    end
  end

  describe 'Scope' do
    let!(:active_job) { create(:job, company: company, status: 'active') }
    let!(:draft_job) { create(:job, company: company, status: 'draft') }
    let!(:other_job) { create(:job, company: other_company, status: 'active') }

    context 'for admin user' do
      it 'returns all jobs' do
        expect(Pundit.policy_scope(admin_user, Job)).to include(active_job, draft_job, other_job)
      end
    end

    context 'for company user' do
      it 'returns only own company jobs' do
        scope = Pundit.policy_scope(company_user, Job)
        expect(scope).to include(active_job, draft_job)
        expect(scope).not_to include(other_job)
      end
    end

    context 'for job seeker' do
      it 'returns only active jobs' do
        scope = Pundit.policy_scope(job_seeker_user, Job)
        expect(scope).to include(active_job, other_job)
        expect(scope).not_to include(draft_job)
      end
    end
  end
end
