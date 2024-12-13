class Event < ApplicationRecord
  #SearchBar
  include PgSearch::Model
  pg_search_scope :global_search,
                  against: %i[name location],
                  using: {
                    tsearch: { prefix: true }
                  }
                  
  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags
  has_many :requests
  has_many :groups
  has_many :favorite_events, dependent: :destroy
  has_many :favorited_by, through: :favorite_events, source: :user
  has_one_attached :image


  # Validations
  validates :location, presence: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :name }
  validates :name, presence: true
  validates :name, uniqueness: { scope: :date }
 
end
