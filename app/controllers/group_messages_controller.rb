class GroupMessagesController < ApplicationController
  def index
    @group = Group.find(params[:id])
    @messages = GroupMessage.where(group: @group)
    @message = GroupMessage.new
  end

  def create_message
    @group = Group.find(params[:id])
    @message = GroupMessage.new(message_params)
    @message.user = current_user
    @message.group = @group
    if @message.save
      redirect_to messages_path
    else
      redirect_to root_path
    end
  end

  private

  def message_params
    params.require(:group_message).permit(:message)
  end
end
