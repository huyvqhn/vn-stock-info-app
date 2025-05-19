# frozen_string_literal: true
require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(Rails.root.join('config/sidekiq.yml'))['schedule']
    Sidekiq::Scheduler.reload_schedule!
  end
end

Rails.application.config.active_job.queue_adapter = :sidekiq