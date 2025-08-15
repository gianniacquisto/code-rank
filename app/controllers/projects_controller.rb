class ProjectsController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @projects = Project.order(sort_column + " " + sort_direction)
  end

  private

  def sort_column
    Project.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
