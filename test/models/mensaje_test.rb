# frozen_string_literal: true

require 'test_helper'

class MensajeTest < ActiveSupport::TestCase
  def setup
    id = SecureRandom.hex(4)

    @paciente = User.create!(
      firstname: 'Laura',
      lastname: 'Fernández',
      username: 'ANITA123',
      email: "laura#{id}@example.com",
      password: 'password',
      rol: :paciente,
      phone: 21_312_312
    )

    @doctor = User.create!(
      firstname: 'Miguel',
      lastname: 'Soto',
      username: 'ANITA123',
      email: "miguel#{id}@example.com",
      password: 'password',
      rol: :doctor,
      phone: 21_312_312
    )

    @reserva = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: 1.day.from_now,
      duracion: 12,
      motivo: 'Consulta médica',
      ubicacion: 'Clínica Central'
    )

    @mensaje = Mensaje.new(
      reserva: @reserva,
      user: @paciente,
      contenido: 'Hola doctor, tengo una consulta previa a la cita.'
    )
  end

  test 'mensaje con contenido muy largo sigue siendo válido' do
    @mensaje.contenido = 'A' * 5000
    assert_predicate @mensaje, :valid?
  end
end
