class RemoveCategoryFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :category, :string
  end
end
