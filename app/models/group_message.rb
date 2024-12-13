class GroupMessage < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :message, presence: true
end
