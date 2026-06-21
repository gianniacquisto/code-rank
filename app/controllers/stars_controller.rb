class StarsController < ApplicationController
  before_action :authenticate_user!

  def create
    @technology = Technology.find(params[:technology_id])
    @star = @technology.stars.find_or_initialize_by(user: Current.session.user)
    @star.starred = true
    @star.save!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @technology }
    end
  end

  def destroy
    @technology = Technology.find(params[:technology_id])
    @star = @technology.stars.find_by(user: Current.session.user)
    @star&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @technology }
    end
  end
end
