module ElasticsearchJob
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    index_name "jobs_#{Rails.env}"

    settings index: {
      number_of_shards: 1,
      number_of_replicas: 0,
      analysis: {
        analyzer: {
          custom_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            filter: ['lowercase', 'stop', 'snowball']
          }
        }
      }
    } do
      mapping do
        indexes :id, type: 'integer'
        indexes :title, type: 'text', analyzer: 'custom_analyzer'
        indexes :description, type: 'text', analyzer: 'custom_analyzer'
        indexes :requirements, type: 'text', analyzer: 'custom_analyzer'
        indexes :location, type: 'text', analyzer: 'custom_analyzer'
        indexes :employment_type, type: 'keyword'
        indexes :salary_min, type: 'integer'
        indexes :salary_max, type: 'integer'
        indexes :remote, type: 'boolean'
        indexes :status, type: 'keyword'
        indexes :company_id, type: 'integer'
        indexes :company_name, type: 'text', analyzer: 'custom_analyzer'
        indexes :company_industry, type: 'keyword'
        indexes :company_size, type: 'keyword'
        indexes :created_at, type: 'date'
        indexes :updated_at, type: 'date'
      end
    end
  end

  def as_indexed_json(options = {})
    {
      id: id,
      title: title,
      description: description,
      requirements: requirements,
      location: location,
      employment_type: employment_type,
      salary_min: salary_min,
      salary_max: salary_max,
      remote: remote,
      status: status,
      company_id: company_id,
      company_name: company&.name,
      company_industry: company&.industry,
      company_size: company&.size,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  class_methods do
    def search_jobs(query, filters = {})
      search_definition = {
        query: {
          bool: {
            must: [],
            filter: []
          }
        },
        sort: [
          { created_at: { order: 'desc' } }
        ],
        highlight: {
          fields: {
            title: {},
            description: {},
            requirements: {},
            company_name: {}
          }
        }
      }

      # Add text search
      if query.present?
        search_definition[:query][:bool][:must] << {
          multi_match: {
            query: query,
            fields: ['title^2', 'description', 'requirements', 'company_name'],
            type: 'best_fields',
            fuzziness: 'AUTO'
          }
        }
      else
        search_definition[:query][:bool][:must] << { match_all: {} }
      end

      # Add filters
      if filters[:location].present?
        search_definition[:query][:bool][:filter] << {
          match: { location: filters[:location] }
        }
      end

      if filters[:employment_type].present?
        search_definition[:query][:bool][:filter] << {
          term: { employment_type: filters[:employment_type] }
        }
      end

      if filters[:remote].present?
        search_definition[:query][:bool][:filter] << {
          term: { remote: filters[:remote] }
        }
      end

      if filters[:salary_min].present? || filters[:salary_max].present?
        salary_range = {}
        salary_range[:gte] = filters[:salary_min] if filters[:salary_min].present?
        salary_range[:lte] = filters[:salary_max] if filters[:salary_max].present?
        
        search_definition[:query][:bool][:filter] << {
          range: { salary_min: salary_range }
        }
      end

      if filters[:company_industry].present?
        search_definition[:query][:bool][:filter] << {
          term: { company_industry: filters[:company_industry] }
        }
      end

      # Only show active jobs
      search_definition[:query][:bool][:filter] << {
        term: { status: 'active' }
      }

      search(search_definition)
    end

    def suggest_jobs(query)
      search_definition = {
        suggest: {
          job_suggestions: {
            prefix: query,
            completion: {
              field: 'title.suggest',
              size: 10
            }
          }
        }
      }

      search(search_definition)
    end

    def reindex_all
      Job.__elasticsearch__.create_index!(force: true)
      Job.import(force: true)
    end

    def delete_index
      Job.__elasticsearch__.delete_index!
    end
  end
end