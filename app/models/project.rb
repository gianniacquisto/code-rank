class Project < ApplicationRecord
    has_many :votes, dependent: :destroy

    def net_votes
        votes.sum(:vote)
    end
end