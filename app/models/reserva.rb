class Reserva < ApplicationRecord
  belongs_to :paciente, class_name: 'User'
  belongs_to :doctor, class_name: 'User'
  has_many :mensajes, dependent: :destroy
  enum estado: { pendiente: 0, confirmada: 1, cancelada: 2, completada: 3 }
end