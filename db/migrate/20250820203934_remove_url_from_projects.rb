class RemoveUrlFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :url, :string
  end
end
