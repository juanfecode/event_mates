class RequestsController < ApplicationController
  def index
    @requests = Request.all.order(id: :desc)
  end
end
