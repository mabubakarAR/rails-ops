require 'rails_helper'

RSpec.describe Api::V1::JobsController, type: :controller do
  let(:user) { create(:user, :company) }
  let(:company) { create(:company, user: user) }
  let(:job) { create(:job, company: company) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:jobs) { create_list(:job, 3, company: company) }

    it 'returns successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns jobs data' do
      get :index
      json_response = JSON.parse(response.body)
      expect(json_response['data']['jobs']).to be_present
    end

    context 'with filters' do
      let!(:remote_job) { create(:job, company: company, remote: true) }

      it 'filters by remote jobs' do
        get :index, params: { remote: 'true' }
        json_response = JSON.parse(response.body)
        expect(json_response['data']['jobs'].length).to eq(1)
      end

      it 'filters by active jobs' do
        create(:job, company: company, status: 'draft')
        get :index, params: { active_only: 'true' }
        json_response = JSON.parse(response.body)
        expect(json_response['data']['jobs'].all? { |job| job['status'] == 'active' }).to be true
      end
    end
  end

  describe 'GET #show' do
    it 'returns job details' do
      get :show, params: { id: job.id }
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).to eq(job.id)
    end
  end

  describe 'POST #create' do
    let(:job_params) do
      {
        job: {
          title: 'Senior Developer',
          description: 'A great opportunity for a senior developer',
          requirements: '5+ years experience',
          benefits: 'Competitive salary',
          location: 'San Francisco',
          salary_min: 80000,
          salary_max: 120000,
          employment_type: 'full_time',
          remote: false
        }
      }
    end

    it 'creates a new job' do
      expect {
        post :create, params: job_params
      }.to change(Job, :count).by(1)
    end

    it 'returns created job' do
      post :create, params: job_params
      expect(response).to have_http_status(:created)
      
      json_response = JSON.parse(response.body)
      expect(json_response['data']['title']).to eq('Senior Developer')
    end
  end

  describe 'PUT #update' do
    let(:update_params) do
      {
        id: job.id,
        job: {
          title: 'Updated Title',
          status: 'active'
        }
      }
    end

    it 'updates the job' do
      put :update, params: update_params
      expect(response).to have_http_status(:ok)
      
      job.reload
      expect(job.title).to eq('Updated Title')
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the job' do
      expect {
        delete :destroy, params: { id: job.id }
      }.to change(Job, :count).by(-1)
    end

    it 'returns success message' do
      delete :destroy, params: { id: job.id }
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Job deleted successfully')
    end
  end
end
