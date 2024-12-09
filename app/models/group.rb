class Group < ApplicationRecord
  belongs_to :user
  belongs_to :event
  has_many :group_messages
end
