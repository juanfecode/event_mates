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
    profiles = User.all
    profiles.each do |profile|
      matching_score = (profile.matching_profile - user_tags)
      if matching_score.empty?
        perfect_coincidence << profile
      elsif !matching_score.empty? && matching_score.size.fdiv(user_tags.size) < 0.3
        coincidence << profile
      end
    end
    suggested_profiles = perfect_coincidence + coincidence
    suggested_profiles.reject { |profile| profile == user }
  end
end
