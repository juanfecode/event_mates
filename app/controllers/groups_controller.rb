class GroupsController < ApplicationController
  def index
  end

  def new
    @group = Group.new
    @event = Event.find(params[:id])
    @users = User.all.reject { |user| user == current_user }
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def group_params
    params.require(:group).permit(:event_id, :bio, :user_id)
  end
end
