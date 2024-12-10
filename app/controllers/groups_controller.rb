class GroupsController < ApplicationController
  def index
  end

  def new
    @group = Group.new
    @event = Event.find(params[:id])
    @users = User.all.reject { |user| user == current_user }
  end

  def create
    updated_params = group_params
    updated_params[:event] = Event.find(params[:group][:event_id])
    @group = Group.new(updated_params)
    @users = User.all
    users_invited = params[:group][:user].reject(&:blank?)
    if @group.save
      users_invited.each { |user| Request.create(group: @group, event: @group.event, user: User.find(user)) }
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
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
    params.require(:group).permit(:event_id, :bio, :user_id, :event, :user)
  end
end
