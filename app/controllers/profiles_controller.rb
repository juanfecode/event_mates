class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @suggested_events = event_score
    @suggested_profiles = profile_score
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :dob, :photo)
  end

  def event_score
    perfect_coincidence = []
    coincidence = []
    user = User.find(params[:id])
    user_tags = user.matching_profile
    Event.all.each do |event|
      matching_score = (event.matching_event - user_tags).size
      if matching_score.zero?
        perfect_coincidence << event
      elsif matching_score == 1
        coincidence << event
      end
    end
    perfect_coincidence + coincidence
  end

  def profile_score
    perfect_coincidence = []
    coincidence = []
    user = User.find(params[:id])
    user_tags = user.matching_profile
    User.all.each do |u|
      matching_score = (u.matching_profile - user_tags)
      if matching_score == []
        perfect_coincidence << u
      elsif user_tags.size.zero? || (user_tags.size - matching_score.size) / user_tags.size < 0.2
        coincidence << u
      end
    end
    perfect_coincidence + coincidence
  end
end
