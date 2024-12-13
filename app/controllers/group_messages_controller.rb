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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:messages, partial: "group_messages/message",
                                                              locals: { message: @message })
        end
        format.html { redirect_to messages_path }
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:group_message).permit(:message)
  end
end
