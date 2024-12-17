class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @events = Event.all
  end

  def about_us
  end
end
