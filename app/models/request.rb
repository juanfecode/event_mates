class Request < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :group
  after_create_commit :broadcast_notification

  validates :user, uniqueness: { scope: %i[group status] }

  def broadcast_notification
    return unless status == "pending_join"

    broadcast_append_to "profile_#{user.id}_notifications",
                        partial: "shared/profile_notification_dot",
                        target: "profile-dropdown",
                        locals: { user: user }

    # broadcast_replace_to "profile_#{user.id}_notifications",
    #                      partial: "shared/invite_notification",
    #                      target: "invitations",
    #                      locals: { event: event, group: group, request: self }
  end
end
