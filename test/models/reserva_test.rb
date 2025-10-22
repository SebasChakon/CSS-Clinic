=begin
require "test_helper"

class ReservaTest < ActiveSupport::TestCase
  def setup
    @paciente = User.create!(
      firstname: "Mario",
      lastname: "Suárez",
      email: "paciente_#{SecureRandom.hex(3)}@example.com",
      password: "password",
      role: "paciente"
    )
    @doctor = User.create!(
      firstname: "Dra",
      lastname: "Rojas",
      email: "doctor_#{SecureRandom.hex(3)}@example.com",
      password: "password",
      role: "doctor"
    )
    @reserva = Reserva.new(
      paciente: @paciente,
      doctor: @doctor,
      fecha: Time.now,
      motivo: "Chequeo",
      ubicacion: "Clínica Central",
      duracion: 60
    )
  end

  test "reserva válida con todos los atributos" do
    assert @reserva.valid?
  end

  test "reserva inválida sin ubicación" do
    @reserva.ubicacion = nil
    assert_not @reserva.valid?
  end

  test "reserva inválida sin duración" do
    @reserva.duracion = nil
    assert_not @reserva.valid?
  end

  test "reserva inválida si duración no es positiva" do
    @reserva.duracion = -10
    assert_not @reserva.valid?
  end

  test "average_rating devuelve 0 si no hay reseñas" do
    assert_equal 0, @reserva.average_rating
  end
end
=end