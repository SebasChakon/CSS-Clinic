require "test_helper"

class ReservaTest < ActiveSupport::TestCase
  def setup
    uid = SecureRandom.hex(4)
    @paciente = User.create!(
      email: "paciente#{uid}@example.com",
      password: "password123",
      username: "ANITA123",
      firstname: "Juan",
      lastname: "Pérez",
      rol: :paciente,
      phone: 21312312

    )

    @doctor = User.create!(
      email: "doctor#{uid}@example.com",
      password: "password123",
      username: "ANITA123",
      firstname: "Ana",
      lastname: "García",
      rol: :doctor,
      phone: 21312312
    )

    @reserva = Reserva.new(
      paciente: @paciente,
      doctor: @doctor,
      duracion: 60,
      ubicacion: "Clínica Central",
      estado: :pendiente,
      fecha_hora: Time.current - 2.hours
    )
  end

  test "reserva válida con datos correctos" do
    assert @reserva.valid?
  end

  test "no válida sin duración" do
    @reserva.duracion = nil
    assert_not @reserva.valid?
    assert_includes @reserva.errors[:duracion], "can't be blank"
  end

  test "no válida con duración negativa" do
    @reserva.duracion = -15
    assert_not @reserva.valid?
  end

  test "no válida sin ubicación" do
    @reserva.ubicacion = nil
    assert_not @reserva.valid?
  end

  test "reserva pertenece a un paciente" do
    assert_equal @paciente, @reserva.paciente
  end

  test "reserva pertenece a un doctor" do
    assert_equal @doctor, @reserva.doctor
  end
end