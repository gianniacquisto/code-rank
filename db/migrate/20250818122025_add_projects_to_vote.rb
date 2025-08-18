class AddProjectsToVote < ActiveRecord::Migration[8.0]
  def change
    add_reference :votes, :project, null: false, foreign_key: true
  end
end
