# frozen_string_literal: true

# Throwaway check that the queue database carries the solid_queue 1.7.0 batch
# shape, and that a batch can actually be enqueued against it.
#
# The app's test environment defines no queue connection (the queue runs only
# in production), so this check runs in its own process and owns a scratch
# SQLite file:
#
#   1. loads db/queue_schema.rb into the scratch file (the fresh-install shape)
#   2. drops the batch parts - reverting to the pre-1.7.0 shape the production
#      queue volume still carries
#   3. runs the db/queue_migrate migrations - they must apply the delta
#   4. enqueues a SolidQueue::Batch with one job through the solid_queue
#      adapter and verifies the tracking rows
#
# Run: RAILS_ENV=test bin/rails runner script/check_queue_batches.rb

require "fileutils"

def check(condition, message)
  return if condition

  abort "queue batch check failed: #{message}"
end

scratch = Rails.root.join("tmp", "queue_batch_check.sqlite3")
FileUtils.rm_f(scratch)

# This process is dedicated to the check, so the default connection can be
# pointed at the scratch file; the SolidQueue models and the schema load use it.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: scratch.to_s)

# Fresh queue database from the repo schema (the solid_queue 1.7.0 install shape).
ActiveRecord::Schema.verbose = false
load Rails.root.join("db", "queue_schema.rb")

connection = ActiveRecord::Base.connection
check(connection.table_exists?(:solid_queue_batches), "db/queue_schema.rb must define solid_queue_batches")
check(connection.table_exists?(:solid_queue_batch_executions), "db/queue_schema.rb must define solid_queue_batch_executions")
check(connection.column_exists?(:solid_queue_jobs, :batch_id), "db/queue_schema.rb must give solid_queue_jobs a batch_id column")

# Revert to the pre-1.7.0 shape (what the production queue volume carries), so
# the migrations below must actually apply the delta instead of being no-ops.
connection.drop_table :solid_queue_batch_executions
connection.drop_table :solid_queue_batches
connection.remove_index :solid_queue_jobs, name: "index_solid_queue_jobs_on_batch_id"
connection.remove_column :solid_queue_jobs, :batch_id
check(!connection.column_exists?(:solid_queue_jobs, :batch_id), "setup should have reverted solid_queue_jobs to the pre-1.7.0 shape")

# The queue migrations must take that shape to 1.7.0.
pool = ActiveRecord::Base.connection_pool
context = ActiveRecord::MigrationContext.new(
  [ Rails.root.join("db", "queue_migrate").to_s ],
  pool.schema_migration,
  pool.internal_metadata
)
context.migrate

check(connection.column_exists?(:solid_queue_jobs, :batch_id), "queue migrations must add solid_queue_jobs.batch_id")
check(connection.table_exists?(:solid_queue_batches), "queue migrations must create solid_queue_batches")
check(connection.table_exists?(:solid_queue_batch_executions), "queue migrations must create solid_queue_batch_executions")
check(SolidQueue::Batch.migrated?, "SolidQueue::Batch.migrated? should be true after the queue migrations")

# The feature itself: enqueue a batch with one job through the solid_queue adapter.
adapter_was = ActiveJob::Base.queue_adapter
batch = nil
begin
  ActiveJob::Base.queue_adapter = :solid_queue
  batch = SolidQueue::Batch.enqueue(description: "CI queue schema check") do
    SitemapRefreshJob.perform_later
  end
ensure
  ActiveJob::Base.queue_adapter = adapter_was
end

check(batch&.persisted?, "SolidQueue::Batch.enqueue should create a batch")
check(SolidQueue::Job.where(batch_id: batch.id).count == 1, "the enqueued job should be tracked on the batch")
check(SolidQueue::BatchExecution.where(batch_id: batch.id).count == 1, "the job should have a batch execution row")
check(SolidQueue::ReadyExecution.count == 1, "the job should sit in the ready executions")

puts "queue batch check passed: batch #{batch.id} with 1 ready job on #{File.basename(scratch)}"
FileUtils.rm_f(scratch)
