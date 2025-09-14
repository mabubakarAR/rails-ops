require 'elasticsearch/model'

class Job
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text', analyzer: 'english'
      indexes :description, type: 'text', analyzer: 'english'
      indexes :requirements, type: 'text', analyzer: 'english'
      indexes :benefits, type: 'text', analyzer: 'english'
      indexes :location, type: 'keyword'
      indexes :employment_type, type: 'keyword'
      indexes :status, type: 'keyword'
      indexes :remote, type: 'boolean'
      indexes :salary_min, type: 'integer'
      indexes :salary_max, type: 'integer'
      indexes :company_name, type: 'text', analyzer: 'english'
      indexes :company_industry, type: 'keyword'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
    end
  end

  def as_indexed_json(options = {})
    as_json(
      only: [:id, :title, :description, :requirements, :benefits, :location, 
             :employment_type, :status, :remote, :salary_min, :salary_max, 
             :created_at, :updated_at],
      include: {
        company: {
          only: [:name, :industry]
        }
      }
    ).merge(
      company_name: company&.name,
      company_industry: company&.industry
    )
  end

  def self.search_jobs(query, filters = {})
    search_definition = {
      query: {
        bool: {
          must: [],
          filter: []
        }
      },
      sort: [
        { created_at: { order: 'desc' } }
      ]
    }

    if query.present?
      search_definition[:query][:bool][:must] << {
        multi_match: {
          query: query,
          fields: ['title^3', 'description^2', 'requirements', 'company_name^2'],
          type: 'best_fields',
          fuzziness: 'AUTO'
        }
      }
    else
      search_definition[:query][:bool][:must] << { match_all: {} }
    end

    filters.each do |key, value|
      case key
      when :location
        search_definition[:query][:bool][:filter] << {
          wildcard: { location: "*#{value}*" }
        }
      when :employment_type
        search_definition[:query][:bool][:filter] << {
          term: { employment_type: value }
        }
      when :remote
        search_definition[:query][:bool][:filter] << {
          term: { remote: value }
        }
      when :salary_min
        search_definition[:query][:bool][:filter] << {
          range: { salary_min: { gte: value } }
        }
      when :salary_max
        search_definition[:query][:bool][:filter] << {
          range: { salary_max: { lte: value } }
        }
      when :company_industry
        search_definition[:query][:bool][:filter] << {
          term: { company_industry: value }
        }
      end
    end

    search_definition[:query][:bool][:filter] << {
      term: { status: 'active' }
    }

    __elasticsearch__.search(search_definition)
  end

  def self.search_suggestions(query)
    search_definition = {
      suggest: {
        job_suggestions: {
          prefix: query,
          completion: {
            field: 'title_suggest',
            size: 10
          }
        }
      }
    }

    __elasticsearch__.search(search_definition)
  end
end
