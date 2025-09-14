require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'associations' do
    it { should belong_to(:company) }
    it { should have_many(:job_applications).dependent(:destroy) }
    it { should have_many(:job_seekers).through(:job_applications) }
    it { should have_many(:job_categories).dependent(:destroy) }
    it { should have_many(:categories).through(:job_categories) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(100) }
    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_least(20).is_at_most(5000) }
    it { should validate_presence_of(:requirements) }
    it { should validate_length_of(:requirements).is_at_least(10).is_at_most(2000) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:employment_type) }
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:salary_min).is_greater_than(0) }
    it { should validate_numericality_of(:salary_max).is_greater_than(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:employment_type).with_values(full_time: 'full_time', part_time: 'part_time', contract: 'contract', freelance: 'freelance', internship: 'internship').backed_by_column_of_type(:string) }
    it { should define_enum_for(:status).with_values(draft: 'draft', active: 'active', paused: 'paused', closed: 'closed').backed_by_column_of_type(:string) }
  end

  describe 'scopes' do
    let!(:active_job) { create(:job, :active) }
    let!(:draft_job) { create(:job, :draft) }
    let!(:remote_job) { create(:job, remote: true) }

    describe '.active' do
      it 'returns only active jobs' do
        expect(Job.active).to include(active_job)
        expect(Job.active).not_to include(draft_job)
      end
    end

    describe '.remote' do
      it 'returns only remote jobs' do
        expect(Job.remote).to include(remote_job)
        expect(Job.remote).not_to include(active_job)
      end
    end

    describe '.recent' do
      it 'orders jobs by created_at desc' do
        expect(Job.recent.first).to eq(Job.order(created_at: :desc).first)
      end
    end
  end

  describe 'methods' do
    let(:job) { create(:job, salary_min: 50000, salary_max: 80000) }

    describe '#salary_range' do
      it 'returns formatted salary range' do
        expect(job.salary_range).to eq('50000 - 80000')
      end

      context 'when only salary_min is present' do
        let(:job_min_only) { create(:job, salary_min: 50000, salary_max: nil) }
        
        it 'returns only minimum salary' do
          expect(job_min_only.salary_range).to eq('50000')
        end
      end

      context 'when only salary_max is present' do
        let(:job_max_only) { create(:job, salary_min: nil, salary_max: 80000) }
        
        it 'returns only maximum salary' do
          expect(job_max_only.salary_range).to eq('Up to 80000')
        end
      end
    end

    describe '#days_since_posted' do
      it 'returns correct number of days' do
        job.update(created_at: 5.days.ago)
        expect(job.days_since_posted).to eq(5)
      end
    end

    describe '#is_recent?' do
      context 'when job was posted within 7 days' do
        it 'returns true' do
          job.update(created_at: 3.days.ago)
          expect(job.is_recent?).to be true
        end
      end

      context 'when job was posted more than 7 days ago' do
        it 'returns false' do
          job.update(created_at: 10.days.ago)
          expect(job.is_recent?).to be false
        end
      end
    end

    describe '#can_apply?' do
      let(:job_seeker) { create(:job_seeker) }
      let(:active_job) { create(:job, :active) }

      context 'when job is active and no application exists' do
        it 'returns true' do
          expect(active_job.can_apply?(job_seeker)).to be true
        end
      end

      context 'when job is not active' do
        let(:draft_job) { create(:job, :draft) }
        
        it 'returns false' do
          expect(draft_job.can_apply?(job_seeker)).to be false
        end
      end

      context 'when application already exists' do
        before { create(:job_application, job: active_job, job_seeker: job_seeker) }
        
        it 'returns false' do
          expect(active_job.can_apply?(job_seeker)).to be false
        end
      end
    end
  end
end
