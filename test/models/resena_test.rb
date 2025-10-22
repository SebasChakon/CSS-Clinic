require "test_helper"

class ResenaTest < ActiveSupport::TestCase
  def setup
    uid = SecureRandom.hex(4)

    @paciente = User.create!(
      firstname: "Ana",
      lastname: "López",
      username: "ANITA123",
      email: "ana#{uid}@example.com",
      password: "password",
      rol: :paciente,
      phone: 21312312
    )

    @doctor = User.create!(
      firstname: "Carlos",
      lastname: "Mora",
      username: "ANITA123",
      email: "carlos#{uid}@example.com",
      password: "password",
      rol: :doctor,
      phone: 21312312
    )

    @reserva = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: Time.current - 2.days, # ya ocurrió
      motivo: "Chequeo general",
      ubicacion: "Clínica Central",
      duracion: 45
    )

    @resena = Resena.new(
      reserva: @reserva,
      autor: @paciente,
      rating: 5,
      comment: "Excelente atención del doctor."
    )
  end

  test "resena válida con todos los atributos correctos" do
    assert @resena.valid?
  end

  test "resena inválida sin rating" do
    @resena.rating = nil
    assert_not @resena.valid?
    assert_includes @resena.errors[:rating], "can't be blank"
  end

  test "rating debe estar entre 1 y 5" do
    @resena.rating = 6
    assert_not @resena.valid?
    @resena.rating = 0
    assert_not @resena.valid?
  end

  test "comment puede estar en blanco pero no superar los 1000 caracteres" do
    @resena.comment = ""
    assert @resena.valid?
    @resena.comment = "a" * 1001
    assert_not @resena.valid?
  end

  test "reserva debe haber ocurrido o estar completada" do
    @reserva.update!(fecha_hora: Time.current + 1.day) # aún no ocurrió
    refute @resena.valid?
    assert_includes @resena.errors[:reserva], "la cita aún no ha ocurrido"
  end

  test "no se permite más de una reseña por paciente y reserva" do
    @resena.save!
    duplicada = @resena.dup
    refute duplicada.valid?
    assert_includes duplicada.errors[:autor_id], "ya dejó una reseña para esta reserva"
  end
end