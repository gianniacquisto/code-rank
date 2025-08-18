class Project < ApplicationRecord
    has_many :votes, dependent: :destroy

    def net_votes
        votes.where(project_id: :id).sum(:vote)
    end
end