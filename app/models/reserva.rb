class Reserva < ApplicationRecord
  belongs_to :paciente, class_name: 'User'
  belongs_to :doctor, class_name: 'User'
  has_many :mensajes, dependent: :destroy
  has_many :resenas, dependent: :destroy
  enum estado: { pendiente: 0, confirmada: 1, cancelada: 2, completada: 3 }
  validates :duracion, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :ubicacion, presence: true

  def average_rating
    resenas.average(:rating)&.round(1) || 0
    
  end
  
end