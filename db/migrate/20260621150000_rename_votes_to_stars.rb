# Renames the votes system to a stars system (GitHub-style).
# - Table: votes → stars
# - Column: vote (integer) → starred (boolean)
# - Data: vote=1 → starred=true, everything else → starred=false
class RenameVotesToStars < ActiveRecord::Migration[8.1]
  def up
    # Create new stars table with correct schema
    create_table :stars do |t|
      t.references :technology, null: false, foreign_key: { to_table: :technologies }
      t.references :user, null: false, foreign_key: true
      t.boolean :starred, null: false, default: false
      t.timestamps null: false
    end

    # Migrate data: vote=1 → starred=true, everything else → starred=false
    execute <<-SQL
      INSERT INTO stars (id, created_at, updated_at, technology_id, user_id, starred)
      SELECT id, created_at, updated_at, technology_id, user_id,
             CASE WHEN vote = 1 THEN 1 ELSE 0 END
      FROM votes
    SQL

    # Drop old votes table
    drop_table :votes
  end

  def down
    # Recreate votes table
    create_table :votes, id: false do |t|
      t.references :technology, null: false, foreign_key: { to_table: :technologies }
      t.references :user, null: false, foreign_key: true
      t.integer :vote
      t.timestamps null: false
    end

    # Migrate data back: starred=true → vote=1, everything else → vote=0
    execute <<-SQL
      INSERT INTO votes (id, created_at, updated_at, technology_id, user_id, vote)
      SELECT id, created_at, updated_at, technology_id, user_id,
             CASE WHEN starred = 1 THEN 1 ELSE 0 END
      FROM stars
    SQL

    # Drop stars table
    drop_table :stars
  end
end
