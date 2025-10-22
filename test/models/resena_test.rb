=begin
require "test_helper"

class ResenaTest < ActiveSupport::TestCase
  def setup
    @paciente = User.create!(
      firstname: "Lucía",
      lastname: "Campos",
      email: "lucia_#{SecureRandom.hex(3)}@example.com",
      password: "password",
      role: "paciente"
    )
    @doctor = User.create!(
      firstname: "Dr",
      lastname: "Mendoza",
      email: "doc_#{SecureRandom.hex(3)}@example.com",
      password: "password",
      role: "doctor"
    )
    @reserva = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha: Time.now - 1.day,
      motivo: "Consulta general",
      ubicacion: "Clínica Los Andes",
      duracion: 30
    )
    @resena = Resena.new(
      reserva: @reserva,
      autor: @paciente,
      rating: 4,
      comment: "Excelente atención"
    )
  end

  test "reseña válida con rating y autor correcto" do
    assert @resena.valid?
  end

  test "reseña inválida sin rating" do
    @resena.rating = nil
    assert_not @resena.valid?
  end

  test "comment no debe superar los 1000 caracteres" do
    @resena.comment = "a" * 1001
    assert_not @resena.valid?
  end

  test "rating debe estar entre 1 y 5" do
    @resena.rating = 6
    assert_not @resena.valid?
  end
end
=end