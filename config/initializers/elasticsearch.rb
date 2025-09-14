require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: ENV['ELASTICSEARCH_URL'] || 'localhost:9200',
  log: Rails.env.development?
)

if Rails.env.development?
  Elasticsearch::Model.client.transport.logger = Logger.new(STDOUT)
end
