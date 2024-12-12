class EventsController < ApplicationController
  before_action :set_event, only: [:show]
  def index
    if params[:query].present?
      @events = Event.global_search(params[:query])
    else
      @events = Event.all
    end
  end

  def show
    @groups = @event.groups
    # @favorites = @event.favoried_by
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :date, :location)
  end
end
