# frozen_string_literal: true

require 'test_helper'

class MensajeTest < ActiveSupport::TestCase
  def setup
    id = SecureRandom.hex(4)

    @paciente = User.create!(
      firstname: 'Laura',
      lastname: 'Fernández',
      username: "paciente#{id}",
      email: "laura#{id}@example.com",
      password: 'password',
      rol: :paciente,
      phone: 21_312_312
    )

    @doctor = User.create!(
      firstname: 'Miguel',
      lastname: 'Soto',
      username: "doctor#{id}",
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

  test 'mensaje es válido con atributos correctos' do
    assert @mensaje.valid?
  end

  test 'mensaje no es válido sin contenido' do
    @mensaje.contenido = nil
    assert_not @mensaje.valid?
  end

  test 'mensaje no es válido si contenido está vacío' do
    @mensaje.contenido = ''
    assert_not @mensaje.valid?
  end

  test 'mensaje debe pertenecer a una reserva' do
    @mensaje.reserva = nil
    assert_not @mensaje.valid?
  end

  test 'mensaje debe tener un usuario' do
    @mensaje.user = nil
    assert_not @mensaje.valid?
  end

  test 'mensaje de largo extremo sigue siendo válido' do
    @mensaje.contenido = 'A' * 10_000
    assert_predicate @mensaje, :valid?
  end

  test 'se pueden crear múltiples mensajes en la misma reserva' do
    mensaje2 = Mensaje.new(
      reserva: @reserva,
      user: @doctor,
      contenido: 'Hola, ¿qué necesitas?'
    )

    assert mensaje2.valid?
  end

  test 'mensajes se ordenan por fecha de creación (si existe scope)' do
    m1 = Mensaje.create!(
      reserva: @reserva,
      user: @paciente,
      contenido: '1'
    )
    sleep(0.01)
    m2 = Mensaje.create!(
      reserva: @reserva,
      user: @doctor,
      contenido: '2'
    )

    assert_equal [m1, m2], Mensaje.order(:created_at).to_a
  end
end
