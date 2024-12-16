class TagsController < ApplicationController
  def index
    @tags = Tag.all
    @user = current_user
    @user_tags = current_user.tags
  end

  def add_user_tag
    @tag = Tag.find_by(id: params[:tag_id])
    user_tag = UserTag.new(user: current_user, tag: @tag)
    user_tag.save
  end

  def add_event_tag
    @tag = Tag.find(params[:tag_id])
    session[:event_tags] << @tag
  end

  def remove_event_tag
    @tag = Tag.find(params[:tag_id])
    session[:event_tags].delete(session[:event_tags].find { |tag| tag["id"] == @tag.id })
  end

  def remove_user_tag
    @tag = Tag.find_by(id: params[:tag_id])
    user_tag = UserTag.find_by(user: current_user, tag: @tag)
    user_tag&.destroy
    head :ok
  end
end
