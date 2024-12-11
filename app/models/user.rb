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

  def own_groups
    groups
  end
end
