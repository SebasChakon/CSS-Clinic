=begin

require "test_helper"

class MensajeTest < ActiveSupport::TestCase
  def setup
    @usuario = User.create!(
      firstname: "Pablo",
      lastname: "Lagos",
      email: "pablo_#{SecureRandom.hex(3)}@example.com",
      password: "password",
      role: "paciente"
    )
    @reserva = Reserva.create!(
      paciente: @usuario,
      doctor: User.create!(
        firstname: "Dr",
        lastname: "Ortiz",
        email: "dr_#{SecureRandom.hex(3)}@example.com",
        password: "password",
        role: "doctor"
      ),
      fecha: Time.now,
      motivo: "Chequeo",
      ubicacion: "Hospital",
      duracion: 45
    )
  end

  test "mensaje válido con contenido" do
    mensaje = Mensaje.new(contenido: "Hola", user: @usuario, reserva: @reserva)
    assert mensaje.valid?
  end

  test "mensaje inválido sin contenido" do
    mensaje = Mensaje.new(user: @usuario, reserva: @reserva)
    assert_not mensaje.valid?
  end
end
=end