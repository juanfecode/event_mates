class FavoriteEventsController < ApplicationController
  before_action :set_event, only: %i[create destroy]

  def create
    @event.favorited_by << current_user
    redirect_to event_path(@event)
  end

  def destroy
    FavoriteEvent.find(params[:id]).destroy
    redirect_to event_path(@event)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
