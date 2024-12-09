class Event < ApplicationRecord
  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags
  has_many :requests
  has_many :groups
end
