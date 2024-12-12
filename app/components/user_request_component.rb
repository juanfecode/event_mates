# frozen_string_literal: true

class UserRequestComponent < ViewComponent::Base
  attr_reader :member

  def initialize(group)
    @group = group
    @members = @group.members
  end

  def owner?
    @group.owner == helpers.current_user
  end
end
