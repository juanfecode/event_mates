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
    @favorites = @event.favorited_by
    @tags = @event.tags
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to event_path(@event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :date, :location)
  end
end
