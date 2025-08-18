class Vote < ApplicationRecord
    belongs_to :user
    belongs_to :project

    validates :project_id, presence: true
    validates :user_id, presence: true
    validates :vote, numericality: { in: -1..1 }
end
