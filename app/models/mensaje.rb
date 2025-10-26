# frozen_string_literal: true

class Mensaje < ApplicationRecord
  belongs_to :reserva
  belongs_to :user

  validates :contenido, presence: true
end
