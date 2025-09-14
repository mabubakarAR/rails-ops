require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_one(:company).dependent(:destroy) }
    it { should have_one(:job_seeker).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(admin: 'admin', company: 'company', job_seeker: 'job_seeker').backed_by_column_of_type(:string) }
  end

  describe 'methods' do
    let(:user) { create(:user) }

    describe '#full_name' do
      context 'when user is a job seeker' do
        let(:job_seeker_user) { create(:user, :job_seeker) }
        let!(:job_seeker) { create(:job_seeker, user: job_seeker_user) }
        
        it 'returns job seeker full name' do
          expect(job_seeker_user.full_name).to eq("#{job_seeker.first_name} #{job_seeker.last_name}")
        end
      end

      context 'when user is a company' do
        let(:company_user) { create(:user, :company) }
        let!(:company) { create(:company, user: company_user) }
        
        it 'returns company name' do
          expect(company_user.full_name).to eq(company.name)
        end
      end

      context 'when user is admin' do
        let(:admin_user) { create(:user, :admin) }
        
        it 'returns email' do
          expect(admin_user.full_name).to eq(admin_user.email)
        end
      end
    end

    describe '#profile_complete?' do
      context 'when user is a company' do
        let(:company_user) { create(:user, :company) }
        
        context 'with complete profile' do
          let!(:company) { create(:company, user: company_user, name: 'Test Company') }
          
          it 'returns true' do
            expect(company_user.profile_complete?).to be true
          end
        end

        context 'with incomplete profile' do
          it 'returns false' do
            expect(company_user.profile_complete?).to be false
          end
        end
      end

      context 'when user is a job seeker' do
        let(:job_seeker_user) { create(:user, :job_seeker) }
        
        context 'with complete profile' do
          let!(:job_seeker) { create(:job_seeker, user: job_seeker_user, first_name: 'John', last_name: 'Doe') }
          
          it 'returns true' do
            expect(job_seeker_user.profile_complete?).to be true
          end
        end

        context 'with incomplete profile' do
          it 'returns false' do
            expect(job_seeker_user.profile_complete?).to be false
          end
        end
      end
    end
  end
end
