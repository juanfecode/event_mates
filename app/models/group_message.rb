class GroupMessage < ApplicationRecord
  belongs_to :group
  belongs_to :user
  validates :message, presence: true
  after_create_commit :broadcast_message

  private

  def broadcast_message
    broadcast_append_to "group_#{group.id}_messages",
                        partial: "group_messages/message",
                        target: "messages",
                        locals: { message: self, user: user }
  end
end
