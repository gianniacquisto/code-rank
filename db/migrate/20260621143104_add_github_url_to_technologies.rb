class AddGithubUrlToTechnologies < ActiveRecord::Migration[8.1]
  def change
    add_column :technologies, :github_url, :string
    add_index :technologies, :github_url
  end
end
