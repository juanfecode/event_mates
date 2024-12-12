class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :dob, :photo)
  end
end
