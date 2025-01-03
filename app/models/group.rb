class Group < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_many :group_messages
  has_many :requests

  has_many :incoming_requests, -> { where(status: 'pending_allow') }, class_name: "Request"
  has_many :outgoing_requests, -> { where(status: 'pending_join') }, class_name: "Request"

  # Members of group when request has status: accepted
  has_many :accepted_requests, -> { where(status: 'accepted') }, class_name: 'Request'
  has_many :members, through: :accepted_requests, source: :user

  # scope :traer_nombre, ->(name) { where(name: name) }

  validates :bio, presence: true

  def owner
    user
  end

  def owner?(check_user)
    user == check_user
  end

  # @group.requests.where(user: helpers.current_user)
  # def requested_by_user?(check_user)
  #   requests.where(user: check_user).any?
  # end

  # def accepted_request_by?(check_user)
  #   requests.where(user: check_user).where(status: "accepted").any?
  # end
end
