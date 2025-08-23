class ProjectsController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]

  def index
    @pagy, @projects = pagy(Project.all)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.stars = 0
    if @project.save
      redirect_to @project
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def project_params
      params.expect(project: [ :name, :category, :url ])
    end
end
