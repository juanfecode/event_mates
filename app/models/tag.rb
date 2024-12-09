class Tag < ApplicationRecord
  has_many :user_tags, dependent: :destroy
  has_many :users, through: :user_tags
  has_many :event_tags, dependent: :destroy
  has_many :events, through: :event_tags
end
