class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # log them in after sign up # can add this back in later if it works
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome, #{@user.email_address}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
