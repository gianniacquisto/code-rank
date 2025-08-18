class RemoveStarsFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :stars, :integer
  end
end
