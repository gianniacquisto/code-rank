class Star < ApplicationRecord
  belongs_to :user
  belongs_to :technology

  validates :technology_id, presence: true
  validates :user_id, presence: true
  validates :user_id, uniqueness: { scope: :technology_id, message: "already starred" }
end
