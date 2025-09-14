class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :ensure_company_user, only: [:new, :create, :edit, :update, :destroy]

  def index
    @companies = Company.includes(:user, :jobs)
    @companies = @companies.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @companies = @companies.limit(20)
  end

  def show
  end

  def new
    @company = current_user.build_company
  end

  def create
    @company = current_user.build_company(company_params)
    
    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.turbo_stream { render turbo_stream: turbo_stream.prepend('companies', partial: 'companies/company', locals: { company: @company }) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('company_form', partial: 'companies/form', locals: { company: @company }) }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("company_#{@company.id}", partial: 'companies/company', locals: { company: @company }) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('company_form', partial: 'companies/form', locals: { company: @company }) }
      end
    end
  end

  def destroy
    @company.destroy
    
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully deleted.' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove("company_#{@company.id}") }
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def ensure_company_user
    unless current_user.company?
      redirect_to root_path, alert: 'Only company users can manage company profiles.'
    end
  end

  def company_params
    params.require(:company).permit(
      :name, :description, :website, :logo, :headquarters, 
      :industry, :size, :founded_year
    )
  end
end
