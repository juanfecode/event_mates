class GroupsController < ApplicationController
  before_action :set_group, only: %i[show admin]

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
    @event = @group.event
    favorite_users = @group.event.favorited_by.reject { |user| user == current_user }
    @users = favorite_users.reject do |user|
      user.member?(@group) || user.invited_or_requested?(@group)
    end
  end

  def invite_requests
    @group = Group.find(params[:id])
    users_invited = params[:group][:user]
    users_invited.each do |user|
      if @group.requests.where(user: user).where(status: "removed").any?
        @request = @group.requests.where(user: user).where(status: "removed").first
        @request.update(status: "pending_join")
      else
        Request.create(group: @group, event: @group.event, user: User.find(user), status: "pending_join")
      end
    end
    redirect_to admin_group_path(@group)
  end

  def show
    # group set by set_group
    @event = @group.event
  end

  def admin
    # group set by set_group
    @event = @group.event
    if current_user == @group.owner
      @incoming_requests = @group.incoming_requests
      @outgoing_requests = @group.outgoing_requests
    else
      redirect_to @group
    end
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
