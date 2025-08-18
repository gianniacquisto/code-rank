class AddFieldsToVotes < ActiveRecord::Migration[8.0]
  def change
    add_column :votes, :vote, :integer
  end
end
