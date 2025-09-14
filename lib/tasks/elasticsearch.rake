namespace :elasticsearch do
  desc "Create Elasticsearch indices"
  task create_indices: :environment do
    Job.__elasticsearch__.create_index!(force: true)
    puts "Created Elasticsearch indices"
  end

  desc "Delete Elasticsearch indices"
  task delete_indices: :environment do
    Job.__elasticsearch__.delete_index!
    puts "Deleted Elasticsearch indices"
  end

  desc "Reindex all jobs"
  task reindex_jobs: :environment do
    Job.import(force: true)
    puts "Reindexed all jobs"
  end

  desc "Reindex jobs in batches"
  task reindex_jobs_batch: :environment do
    Job.find_in_batches(batch_size: 100) do |batch|
      Job.import(batch, refresh: false)
      puts "Indexed #{batch.size} jobs"
    end
    Job.__elasticsearch__.refresh_index!
    puts "Completed batch reindexing"
  end

  desc "Setup Elasticsearch (create indices and reindex)"
  task setup: [:create_indices, :reindex_jobs] do
    puts "Elasticsearch setup completed"
  end
end
