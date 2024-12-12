class RequestsController < ApplicationController
  def index
    @requests = Request.all.order(id: :desc)
  end

  def invite
  end

  def ask_to_join
    @group =  Group.find(params[:id])
    build_request_to_join
    if @request.save
      redirect_to @group, notice: "Request to join successfully sent"
    else
      redirect_to @group, alert: "Unable to send your request to join this group"
    end
  end

  def ask_to_rejoin
    @request = Request.find(params[:id])
    @request.update(status: "pending_allow")
    redirect_to @request.group
  end

  def request_form
    # authorize :request, :request_form?
    @type = params[:type]
    @request = Request.new
  end

  def approve_request
    @request = Request.find(params[:id])
    @request.update(status: "accepted")
    redirect_to @request.group
  end

  def cancel_request
    @request = Request.find(params[:id])
    @request.destroy
    redirect_to @request.group
  end

  def reject_request
    @request = Request.find(params[:id])
    @request.update(status: "rejected")
    redirect_to @request.group
  end

  def remove_member
    @request = Request.find(params[:id])
    @request.update(status: "removed")
    redirect_to @request.group
  end

  private

  def request_params
    params.require(:request).permit(:message)
  end

  def build_request_to_join
    @request = Request.new(request_params)
    @request.status = "pending_allow"
    @request.event = @group.event
    @request.group = @group
    @request.user = current_user
  end
end
