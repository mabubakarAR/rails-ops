class JobBroadcastJob < ApplicationJob
  queue_as :default

  def perform(job, action)
    case action
    when 'created'
      broadcast_job_created(job)
    when 'updated'
      broadcast_job_updated(job)
    when 'deleted'
      broadcast_job_deleted(job)
    end
  end

  private

  def broadcast_job_created(job)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "jobs",
      target: "jobs",
      partial: "jobs/job",
      locals: { job: job }
    )
  end

  def broadcast_job_updated(job)
    Turbo::StreamsChannel.broadcast_replace_to(
      "jobs",
      target: "job_#{job.id}",
      partial: "jobs/job",
      locals: { job: job }
    )
  end

  def broadcast_job_deleted(job)
    Turbo::StreamsChannel.broadcast_remove_to(
      "jobs",
      target: "job_#{job.id}"
    )
  end
end
