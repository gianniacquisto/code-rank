class TechnologiesController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]

  def index
    @technologies = Technology.all
    @star_counts = Star.group(:technology_id).count
    @user_starred_technology_ids = if authenticated?
      Star.where(user: Current.session.user).pluck(:technology_id)
    else
      []
    end
  end

  def new
    @technology = Technology.new
  end

  def create
    @technology = Technology.new(technology_params)
    if @technology.save
      redirect_to @technology
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def technology_params
    params.expect(technology: [ :name, :github_url ])
  end
end
