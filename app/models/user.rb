class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags
  has_many :favorite_events, dependent: :destroy
  has_many :events, through: :requests
  has_many :requests
  has_many :groups
  has_many :groups_requested, through: :requests, source: :group
  has_many :accepted_requests, -> { where(status: "accepted") }, class_name: "Request"
  has_many :accepted_groups, through: :accepted_requests, source: :group
  has_many :group_messages
  has_one_attached :photo
  has_many :questions
  has_many :invitations, -> { where(status: "pending_join") }, class_name: "Request"

  def own_groups
    groups
  end

  def member?(group)
    accepted_groups.where(id: group.id).any? || self == group.owner
  end

  def invited_or_requested?(group)
    invited = requests.where(group_id: group.id).where(status: "pending_join").any?
    requested = requests.where(group_id: group.id).where(status: "pending_allow").any?
    invited || requested
  end

  def matching_profile
    tags.map(&:id).sort
  end
end
