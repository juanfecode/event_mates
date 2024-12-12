class Request < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :group

  validates :user, uniqueness: { scope: %i[group status] }
end
