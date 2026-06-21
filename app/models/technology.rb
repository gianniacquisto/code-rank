class Technology < ApplicationRecord
  has_many :stars, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :github_url, format: { with: %r{\Ahttps://github.com/[\w.-]+/[\w.-]+\z}, message: "must be a valid GitHub repository URL" }, allow_blank: true

  def star_count
    stars.count
  end
end
