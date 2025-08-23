require "open3"

namespace :data do
  desc "Bulk import repositories from CSV"
  task import: :environment do
    db_file = if Rails.env.production?
                Rails.root.join("storage", "production.sqlite3")
    else
                Rails.root.join("storage", "development.sqlite3")
    end
    csv_dir   = Rails.root.join("storage", "data")

    puts "Starting bulk import..."

    # PRAGMA tuning
    pragma_sql = <<~SQL
      PRAGMA synchronous = NORMAL;
      PRAGMA journal_mode = WAL;
    SQL

    schema_sql = <<~SQL

      DROP TABLE IF EXISTS projects_import;
      CREATE TABLE projects_import (
        name TEXT
      );
    SQL
    Open3.popen2("sqlite3 #{db_file}") { |stdin, stdout| stdin.puts(schema_sql); stdin.close }

    # Import all CSV files in directory
    Dir.glob("#{csv_dir}/watchevent-over-1000.csv").each do |file|
      puts "Importing #{file}..."
      Open3.popen2("sqlite3 #{db_file}") do |stdin, stdout|
        stdin.puts <<~SQL
          .mode csv
          .import --skip 1 #{file} projects_import -v
        SQL
        stdin.close
      end
    end

    # Move from staging table into main table
    current_time = Time.current.utc.strftime("%Y-%m-%d %H:%M:%S")
    Open3.popen2("sqlite3 #{db_file}") do |stdin, stdout|
      stdin.puts <<~SQL
        INSERT INTO projects (name, created_at, updated_at)
        SELECT pi.name, '#{current_time}', '#{current_time}'
        FROM projects_import pi
        WHERE NOT EXISTS (
          SELECT 1
          FROM projects p
          WHERE p.name = pi.name
        );
        DROP TABLE projects_import;
      SQL
      stdin.close
    end


    ActiveRecord::Base.connection.execute("CREATE INDEX IF NOT EXISTS projects_name ON projects(name);")

    puts "Bulk import complete!"
  end
end
