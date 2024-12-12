class TagsController < ApplicationController
  def index
    @tags = Tag.all
    @user = current_user
    @user_tags = current_user.tags
  end

  def add_tag
    @tag = Tag.find_by(id: params[:tag_id])
    user_tag = UserTag.new(user: current_user, tag: @tag)
    user_tag.save
  end

  def remove_tag
    @tag = Tag.find_by(id: params[:tag_id])
    user_tag = UserTag.find_by(user: current_user, tag: @tag)
    user_tag&.destroy
    head :ok
  end
end