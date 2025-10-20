class Resena < ApplicationRecord
  belongs_to :reserva
  belongs_to :autor, class_name: 'User'

  validates :rating, presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
  validates :comment, length: { maximum: 1000 }, allow_blank: true
  validates :autor_id, uniqueness: { scope: :reserva_id, message: 'ya dejó una reseña para esta reserva' }

  validate :autor_es_paciente_de_la_reserva
  validate :reserva_ha_ocurrido_o_completada

  private

  def autor_es_paciente_de_la_reserva
    return unless reserva && autor
    unless reserva.paciente_id == autor.id
      errors.add(:autor, "solo el paciente asociado puede escribir la reseña")
    end
  end

  def reserva_ha_ocurrido_o_completada
    return unless reserva && reserva.fecha_hora
    allowed = reserva.fecha_hora < Time.current || (reserva.respond_to?(:completada?) && reserva.completada?)
    errors.add(:reserva, "la cita aún no ha ocurrido") unless allowed
  end
end
