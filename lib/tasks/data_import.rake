namespace :data do
  desc "Bulk import repositories from CSV"
  task import: :environment do
    db_file   = Rails.root.join("storage", "development.sqlite3")
    csv_dir   = Rails.root.join("storage", "data")

    puts "Starting bulk import..."

    # # PRAGMA tuning
    # pragma_sql = <<~SQL
    #   PRAGMA synchronous = OFF;
    #   PRAGMA journal_mode = OFF;
    #   PRAGMA temp_store = MEMORY;
    #   PRAGMA mmap_size = 34359738368;
    #   PRAGMA cache_size = -1048576;
    #   PRAGMA locking_mode = EXCLUSIVE;
    # SQL

    # Open3.popen2("sqlite3 #{db_file}") { |stdin, stdout| stdin.puts(pragma_sql); stdin.close }

    # Schema creation
    # schema_sql = <<~SQL
    #   DROP TABLE IF EXISTS repositories;
    #   CREATE TABLE repositories (
    #     id   INTEGER PRIMARY KEY AUTOINCREMENT,
    #     name TEXT NOT NULL
    #   );

    #   DROP TABLE IF EXISTS repositories_import;
    #   CREATE TABLE repositories_import (
    #     name TEXT
    #   );
    # SQL

    schema_sql = <<~SQL

      DROP TABLE IF EXISTS projects_import;
      CREATE TABLE projects_import (
        name TEXT
      );
    SQL
    Open3.popen2("sqlite3 #{db_file}") { |stdin, stdout| stdin.puts(schema_sql); stdin.close }

    # Import all CSV files in directory
    Dir.glob("#{csv_dir}/*").each do |file|
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
        SELECT name, '#{current_time}', '#{current_time}'
        FROM projects_import;
        DROP TABLE projects_import;
      SQL
      stdin.close
    end

    # Re-enable safe modes and create index
    # ActiveRecord::Base.connection.execute("PRAGMA journal_mode = WAL;")
    # ActiveRecord::Base.connection.execute("PRAGMA synchronous = NORMAL;")
    # ActiveRecord::Base.connection.execute("CREATE INDEX idx_repositories_name ON repositories(name);")

    puts "Bulk import complete!"
  end
end
