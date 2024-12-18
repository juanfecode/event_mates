class EventsController < ApplicationController
  before_action :set_event, only: [:show]
  def index
    if params[:query].present?
      @events = Event.global_search(params[:query])
    else
      @events = Event.all
    end
    @tags = Tag.by_popularity
  end

  def show
    @groups = @event.groups
    @favorites = @event.favorited_by
    @tags = @event.tags
    @marker = [{
      lat: @event.latitude,
      lng: @event.longitude,
      info_window_html: render_to_string(partial: "event_window", locals: { event: @event })
    }]
  end
  def new
    @event = Event.new
    @tags = Tag.all
    @event.tags = @tags
    session[:event_tags] = []
  end

  def create
    @event = Event.new(event_params)
    @event.address = "#{@event.address}, #{@event.location}"
    if @event.save!
      session[:event_tags].each do |tag|
        @tag = Tag.find(tag["id"])
        @event.tags << @tag
      end
      session[:event_tags] = []
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
    params.require(:event).permit(:name, :date, :location, :description, :address)
  end
end
