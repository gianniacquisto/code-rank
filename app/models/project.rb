class Project < ApplicationRecord
    has_many :votes, dependent: :destroy
    validates :name, presence: true, uniqueness: true

    def net_votes
        votes.sum(:vote)
    end
end
