class StarsController < ApplicationController
  before_action :authenticate_user!

  def create
    @technology = Technology.find(params[:technology_id])
    @star = @technology.stars.find_or_initialize_by(user: Current.session.user)
    @star.starred = true
    @star.save!
    redirect_to root_path
  end

  def destroy
    @technology = Technology.find(params[:technology_id])
    @star = @technology.stars.find_by(user: Current.session.user)
    @star&.destroy
    redirect_to root_path
  end
end
