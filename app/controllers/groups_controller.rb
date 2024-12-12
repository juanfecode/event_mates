class GroupsController < ApplicationController
  before_action :set_group, only: %i[show]

  def index
  end

  def new
    @group = Group.new
    @event = Event.find(params[:id])
    @users = @event.favorited_by.reject { |user| user == current_user }
  end

  def create
    updated_params = group_params
    updated_params[:event] = Event.find(params[:group][:event_id])
    @group = Group.new(updated_params)
    users_invited = params[:group][:user]
    if @group.save
      users_invited.each do |user|
        Request.create(group: @group, event: @group.event, user: User.find(user), status: "pending_join")
      end
      # change the redirect_to
      redirect_to group_path(@group)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def invite
    @group = Group.find(params[:id])
    favorite_users = @group.event.favorited_by.reject { |user| user == current_user }
    @users = favorite_users.reject do |user|
      user.member?(@group) || user.invited_or_requested?(@group)
    end
  end

  def invite_requests
    @group = Group.find(params[:id])
    users_invited = params[:group][:user]
    users_invited.each do |user|
      Request.create(group: @group, event: @group.event, user: User.find(user), status: "pending_join")
    end
    redirect_to group_path(@group)
  end

  def show
    # group set by set_group
    @outgoing_requests = @group.outgoing_requests
    @incoming_requests = @group.incoming_requests
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:event_id, :bio, :user_id, :event, :user)
  end
end
