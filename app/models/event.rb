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

  # Validations
  validates :location, presence: true
  validates :date, presence: true
  validates :date, uniqueness: { scope: :name }
  validates :name, presence: true
  validates :name, uniqueness: { scope: :date }
  validates :capacity, presence: true

end
