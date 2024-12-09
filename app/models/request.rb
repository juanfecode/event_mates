class Request < ApplicationRecord
  belongs_to :user
  belongs_to :event
  belongs_to :group
end
