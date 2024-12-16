class Tag < ApplicationRecord
  has_many :user_tags, dependent: :destroy
  has_many :users, through: :user_tags
  has_many :event_tags, dependent: :destroy
  has_many :events, through: :event_tags

  def self.most_popular
    joins(:event_tags)
      .select("tags.*, COUNT(event_tags.id) AS event_count")
      .group("tags.id")
      .order("event_count DESC")
      .first
  end

  def self.by_popularity
    joins(:event_tags)
      .select("tags.*, COUNT(event_tags.id) AS event_count")
      .group("tags.id")
      .order("event_count DESC")
  end
  
end
