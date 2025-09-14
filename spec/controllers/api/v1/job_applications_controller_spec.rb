require 'rails_helper'

RSpec.describe Api::V1::JobApplicationsController, type: :controller do
  let(:company_user) { create(:user, :company) }
  let(:company) { create(:company, user: company_user) }
  let(:job) { create(:job, company: company) }
  let(:job_seeker_user) { create(:user, :job_seeker) }
  let(:job_seeker) { create(:job_seeker, user: job_seeker_user) }
  let(:job_application) { create(:job_application, job: job, job_seeker: job_seeker) }

  describe 'GET #index' do
    context 'as company user' do
      before { sign_in company_user }

      it 'returns applications for company jobs' do
        get :index
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['job_applications']).to be_present
      end
    end

    context 'as job seeker' do
      before { sign_in job_seeker_user }

      it 'returns job seeker applications' do
        get :index
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['job_applications']).to be_present
      end
    end
  end

  describe 'GET #show' do
    context 'as company user' do
      before { sign_in company_user }

      it 'returns application details' do
        get :show, params: { id: job_application.id }
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(job_application.id)
      end
    end

    context 'as job seeker' do
      before { sign_in job_seeker_user }

      it 'returns own application details' do
        get :show, params: { id: job_application.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST #create' do
    before { sign_in job_seeker_user }

    let(:application_params) do
      {
        job_id: job.id,
        cover_letter: 'I am very interested in this position.'
      }
    end

    it 'creates a new application' do
      expect {
        post :create, params: application_params
      }.to change(JobApplication, :count).by(1)
    end

    it 'returns created application' do
      post :create, params: application_params
      expect(response).to have_http_status(:created)
      
      json_response = JSON.parse(response.body)
      expect(json_response['data']['cover_letter']).to eq('I am very interested in this position.')
    end

    context 'when job is not active' do
      let(:draft_job) { create(:job, company: company, status: 'draft') }
      
      it 'returns error' do
        post :create, params: { job_id: draft_job.id, cover_letter: 'Test' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    context 'as company user' do
      before { sign_in company_user }

      let(:update_params) do
        {
          id: job_application.id,
          job_application: {
            status: 'accepted'
          }
        }
      end

      it 'updates application status' do
        put :update, params: update_params
        expect(response).to have_http_status(:ok)
        
        job_application.reload
        expect(job_application.status).to eq('accepted')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'as job seeker' do
      before { sign_in job_seeker_user }

      it 'withdraws the application' do
        delete :destroy, params: { id: job_application.id }
        expect(response).to have_http_status(:ok)
        
        job_application.reload
        expect(job_application.status).to eq('withdrawn')
      end
    end
  end
end
