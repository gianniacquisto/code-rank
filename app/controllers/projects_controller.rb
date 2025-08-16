class ProjectsController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @projects = Project.order(sort_column + " " + sort_direction)
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

  def sort_column
    Project.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def project_params
      params.expect(project: [ :name, :category, :url ])
    end
end
