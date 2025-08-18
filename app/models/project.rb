class Project < ApplicationRecord
    has_many :votes, dependent: :destroy
end
