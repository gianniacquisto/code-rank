class VotesController < ApplicationController
  def create
    @technology = Technology.find(params[:technology_id])
    @vote = @technology.votes.find_or_initialize_by(user: Current.session.user)
    @vote.vote = params[:vote]
    @vote.save
  end

  private

  def vote_params
    params.require(:vote).permit(:vote, :technology_id)
  end
end
