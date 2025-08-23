class VotesController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @vote = @project.votes.find_or_initialize_by(user: Current.session.user)
    @vote.vote = params[:vote]
    @vote.save
  end

  private

  def vote_params
    params.require(:vote).permit(:vote, :project_id)
  end
end
