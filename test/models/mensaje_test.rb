require "test_helper"

class MensajeTest < ActiveSupport::TestCase
  def setup
    id = SecureRandom.hex(4)
    
    @paciente = User.create!(
      firstname: "Laura",
      lastname: "Fernández",
      username: "ANITA123",
      email: "laura#{id}@example.com",
      password: "password",
      rol: :paciente,
      phone: 21312312
    )

    @doctor = User.create!(
      firstname: "Miguel",
      lastname: "Soto",
      username: "ANITA123",
      email: "miguel#{id}@example.com",
      password: "password",
      rol: :doctor,
      phone: 21312312
    )

    @reserva = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: Time.current + 1.day,
      motivo: "Consulta médica",
      ubicacion: "Clínica Central"
    )

    @mensaje = Mensaje.new(
      reserva: @reserva,
      user: @paciente,
      contenido: "Hola doctor, tengo una consulta previa a la cita."
    )
  end

  test "mensaje válido con todos los atributos" do
    assert @mensaje.valid?
  end

  test "mensaje inválido sin contenido" do
    @mensaje.contenido = nil
    assert_not @mensaje.valid?
    assert_includes @mensaje.errors[:contenido], "can't be blank"
  end

  test "mensaje inválido sin usuario asociado" do
    @mensaje.user = nil
    assert_not @mensaje.valid?
  end

  test "mensaje inválido sin reserva asociada" do
    @mensaje.reserva = nil
    assert_not @mensaje.valid?
  end

  test "mensaje pertenece a una reserva con paciente y doctor válidos" do
    @mensaje.save!
    assert_equal @paciente, @mensaje.reserva.paciente
    assert_equal @doctor, @mensaje.reserva.doctor
  end

  test "no se puede guardar mensaje con reserva inexistente" do
    mensaje_invalido = Mensaje.new(reserva_id: 9999, user: @paciente, contenido: "Hola")
    assert_raises(ActiveRecord::InvalidForeignKey) do
      mensaje_invalido.save(validate: false)
    end
  end

  test "no se puede guardar mensaje con usuario inexistente" do
    mensaje_invalido = Mensaje.new(reserva: @reserva, user_id: 9999, contenido: "Hola")
    assert_raises(ActiveRecord::InvalidForeignKey) do
      mensaje_invalido.save(validate: false)
    end
  end

  test "mensaje con contenido muy largo sigue siendo válido" do
    @mensaje.contenido = "A" * 5000
    assert @mensaje.valid?
  end
end