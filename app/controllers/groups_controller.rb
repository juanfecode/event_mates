class GroupsController < ApplicationController
  def index
  end

  def new
    @group = Group.new
    @event = Event.find(params[:id])
    @users = User.all
  end

  def create
    @group = Group.new(group_params)
    users_invited = params[:group][:user].reject(&:blank?)
    if @group.save
      users_invited.each do |user|
        user_instance = User.find(user)
        request = Request.new
        request.group = @group
        request.event = @group.event
        request.status = "pending"
        request.user = user_instance
        request.save
      end
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
    params.require(:group).permit(:event_id, :bio, :user_id)
  end
end
