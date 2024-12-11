class Event < ApplicationRecord
  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags
  has_many :requests
  has_many :groups
  has_many :favorite_events, dependent: :destroy
  has_many :favorited_by, through: :favorite_events, source: :user
end
