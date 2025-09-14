class Api::V1::SearchController < Api::V1::BaseController
  def jobs
    query = params[:q]
    filters = extract_filters
    
    if query.present? || filters.any?
      results = Job.search_jobs(query, filters)
      jobs = results.records.includes(:company, :categories)
      
      render_success({
        jobs: jobs.map { |job| job_serializer(job) },
        total: results.total,
        aggregations: results.aggregations,
        suggestions: get_suggestions(query)
      })
    else
      render_error('Search query or filters required', :bad_request)
    end
  end

  def companies
    query = params[:q]
    industry = params[:industry]
    size = params[:size]
    
    companies = Company.includes(:user, :jobs)
    
    if query.present?
      companies = companies.where("name LIKE ? OR description LIKE ?", 
                                 "%#{query}%", "%#{query}%")
    end
    
    companies = companies.by_industry(industry) if industry.present?
    companies = companies.by_size(size) if size.present?
    
    companies = paginate(companies)
    
    render_success({
      companies: companies.map { |company| company_serializer(company) },
      pagination: {
        current_page: companies.current_page,
        total_pages: companies.total_pages,
        total_count: companies.total_count,
        per_page: companies.limit_value
      }
    })
  end

  def job_seekers
    query = params[:q]
    location = params[:location]
    experience = params[:experience]
    skills = params[:skills]&.split(',')
    
    job_seekers = JobSeeker.includes(:user, :skills)
    
    if query.present?
      job_seekers = job_seekers.where("first_name LIKE ? OR last_name LIKE ? OR bio LIKE ?", 
                                    "%#{query}%", "%#{query}%", "%#{query}%")
    end
    
    job_seekers = job_seekers.by_location(location) if location.present?
    job_seekers = job_seekers.by_experience(experience.to_i) if experience.present?
    job_seekers = job_seekers.with_skills(skills) if skills.present?
    
    job_seekers = paginate(job_seekers)
    
    render_success({
      job_seekers: job_seekers.map { |job_seeker| job_seeker_serializer(job_seeker) },
      pagination: {
        current_page: job_seekers.current_page,
        total_pages: job_seekers.total_pages,
        total_count: job_seekers.total_count,
        per_page: job_seekers.limit_value
      }
    })
  end

  private

  def extract_filters
    filters = {}
    filters[:location] = params[:location] if params[:location].present?
    filters[:employment_type] = params[:employment_type] if params[:employment_type].present?
    filters[:remote] = params[:remote] == 'true' if params[:remote].present?
    filters[:salary_min] = params[:salary_min].to_i if params[:salary_min].present?
    filters[:salary_max] = params[:salary_max].to_i if params[:salary_max].present?
    filters[:company_industry] = params[:industry] if params[:industry].present?
    filters
  end

  def get_suggestions(query)
    return [] unless query.present? && query.length > 2
    
    suggestions = Job.search_suggestions(query)
    suggestions.dig('suggest', 'job_suggestions', 0, 'options')&.map { |option| option['text'] } || []
  end

  def job_serializer(job)
    {
      id: job.id,
      title: job.title,
      description: job.description,
      requirements: job.requirements,
      benefits: job.benefits,
      location: job.location,
      salary_range: job.salary_range,
      employment_type: job.employment_type,
      remote: job.remote,
      status: job.status,
      days_since_posted: job.days_since_posted,
      is_recent: job.is_recent?,
      company: {
        id: job.company.id,
        name: job.company.name,
        industry: job.company.industry,
        size: job.company.size
      },
      categories: job.categories.map { |cat| { id: cat.id, name: cat.name } },
      total_applications: job.total_applications,
      created_at: job.created_at,
      updated_at: job.updated_at
    }
  end

  def company_serializer(company)
    {
      id: company.id,
      name: company.name,
      description: company.description,
      website: company.website,
      industry: company.industry,
      size: company.size,
      founded_year: company.founded_year,
      headquarters: company.headquarters,
      total_jobs: company.total_jobs,
      active_jobs: company.active_jobs,
      total_applications: company.total_applications,
      created_at: company.created_at,
      updated_at: company.updated_at
    }
  end

  def job_seeker_serializer(job_seeker)
    {
      id: job_seeker.id,
      first_name: job_seeker.first_name,
      last_name: job_seeker.last_name,
      full_name: job_seeker.full_name,
      phone: job_seeker.phone,
      location: job_seeker.location,
      bio: job_seeker.bio,
      experience_years: job_seeker.experience_years,
      skills: job_seeker.skills.map { |skill| { id: skill.id, name: skill.name } },
      total_applications: job_seeker.total_applications,
      pending_applications: job_seeker.pending_applications,
      accepted_applications: job_seeker.accepted_applications,
      profile_completion_percentage: job_seeker.profile_completion_percentage,
      created_at: job_seeker.created_at,
      updated_at: job_seeker.updated_at
    }
  end
end
