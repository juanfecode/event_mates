class GroupMessagesController < ApplicationController
  def index
    @group = Group.find(params[:id])
    @event = @group.event
    if current_user.member?(@group)
      @messages = GroupMessage.where(group: @group)
      @message = GroupMessage.new
    else
      redirect_to @group
    end
  end

  def create_message
    @group = Group.find(params[:id])
    if current_user.member?(@group)
      @messages = GroupMessage.where(group: @group)
      @message = GroupMessage.new(message_params)
      @message.user = current_user
      # @message.session_user = current_user
      @message.group = @group
      if @message.save
        render json: {}, status: :no_content
      else
        render :index, status: :unprocessable_entity
      end
    else
      redirect_to @group
    end
  end

  private

  def message_params
    params.require(:group_message).permit(:message, :session_user)
  end
end
