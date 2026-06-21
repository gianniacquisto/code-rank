class RenameProjectsToTechnologies < ActiveRecord::Migration[8.0]
  def change
    rename_table :projects, :technologies
    rename_column :votes, :project_id, :technology_id
    rename_index :votes, :index_votes_on_project_id, :index_votes_on_technology_id
  end
end
