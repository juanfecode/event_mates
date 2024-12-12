# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  attr_reader :title, :close_on_submit, :size, :show_header, :modal_body_class

  def initialize(title: '', close_on_submit: true, size: '',
                 show_header: true, modal_body_class: '')
    @title = title
    @close_on_submit = close_on_submit
    @size = size
    @show_header = show_header
    @modal_body_class = modal_body_class
  end

  def title?
    @title.present?
  end
end
