require 'rails_helper'

RSpec.describe JobApplication, type: :model do
  describe 'associations' do
    it { should belong_to(:job) }
    it { should belong_to(:job_seeker) }
  end

  describe 'validations' do
    it { should validate_length_of(:cover_letter).is_at_most(2000).allow_blank }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:job_seeker_id).scoped_to(:job_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 'pending', reviewed: 'reviewed', shortlisted: 'shortlisted', interviewed: 'interviewed', accepted: 'accepted', rejected: 'rejected', withdrawn: 'withdrawn') }
  end

  describe 'scopes' do
    let!(:recent_application) { create(:job_application, applied_at: 1.day.ago) }
    let!(:old_application) { create(:job_application, applied_at: 10.days.ago) }
    let!(:pending_application) { create(:job_application, :pending) }
    let!(:accepted_application) { create(:job_application, :accepted) }

    describe '.recent' do
      it 'orders applications by created_at desc' do
        expect(JobApplication.recent.first).to eq(JobApplication.order(created_at: :desc).first)
      end
    end

    describe '.by_status' do
      it 'filters by status' do
        expect(JobApplication.by_status('pending')).to include(pending_application)
        expect(JobApplication.by_status('pending')).not_to include(accepted_application)
      end
    end
  end

  describe 'callbacks' do
    let(:job_application) { build(:job_application) }

    it 'sends notification after create' do
      expect(JobApplicationNotificationJob).to receive(:perform_later).with(job_application, 'new_application')
      job_application.save!
    end

    it 'sends notification after status update' do
      job_application.save!
      expect(JobApplicationNotificationJob).to receive(:perform_later).with(job_application, 'status_update')
      job_application.update!(status: 'accepted')
    end
  end

  describe 'methods' do
    let(:job_application) { create(:job_application, applied_at: 5.days.ago) }

    describe '#days_since_applied' do
      it 'returns correct number of days' do
        expect(job_application.days_since_applied).to eq(5)
      end
    end

    describe '#is_recent_application?' do
      context 'when applied within 3 days' do
        it 'returns true' do
          job_application.update(applied_at: 2.days.ago)
          expect(job_application.is_recent_application?).to be true
        end
      end

      context 'when applied more than 3 days ago' do
        it 'returns false' do
          job_application.update(applied_at: 5.days.ago)
          expect(job_application.is_recent_application?).to be false
        end
      end
    end

    describe '#can_withdraw?' do
      context 'when status allows withdrawal' do
        let(:pending_app) { create(:job_application, :pending) }
        
        it 'returns true' do
          expect(pending_app.can_withdraw?).to be true
        end
      end

      context 'when status does not allow withdrawal' do
        let(:accepted_app) { create(:job_application, :accepted) }
        
        it 'returns false' do
          expect(accepted_app.can_withdraw?).to be false
        end
      end
    end

    describe '#can_update_status?' do
      let(:application) { create(:job_application, :pending) }

      context 'when updating to valid status' do
        it 'returns true' do
          expect(application.can_update_status?('accepted')).to be true
        end
      end

      context 'when application is withdrawn' do
        let(:withdrawn_app) { create(:job_application, status: 'withdrawn') }
        
        it 'returns false' do
          expect(withdrawn_app.can_update_status?('accepted')).to be false
        end
      end

      context 'when trying to change accepted status' do
        let(:accepted_app) { create(:job_application, :accepted) }
        
        it 'returns false' do
          expect(accepted_app.can_update_status?('rejected')).to be false
        end
      end
    end
  end
end
