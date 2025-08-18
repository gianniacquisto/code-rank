class VotesController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @vote = @project.votes.find_or_initialize_by(user: Current.session.user)
    @vote.vote = params[:vote]

    if @vote.save
      redirect_to projects_path, notice: "Vote was successfully recorded."
    else
      redirect_to projects_path, alert: "There was an error recording your vote."
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:vote, :project_id)
  end
end
