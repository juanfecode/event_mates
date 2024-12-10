class Group < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_many :group_messages
  has_many :requests
  has_many :accepted_requests, -> { where(status: 'accepted') }, class_name: 'Request'
  has_many :members, through: :accepted_requests, source: :user
  # scope :traer_nombre, ->(name) { where(name: name) }

  validates :bio, presence: true

  def owner
    user
  end
end
