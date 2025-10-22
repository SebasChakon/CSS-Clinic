require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      firstname: "Ana",
      lastname: "Pérez",
      email: "ana_#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      rol: "paciente"
    )
  end

  # -------------------------------
  # Validaciones básicas
  # -------------------------------
  test "usuario válido con todos los atributos" do
    assert @user.valid?
  end

  test "usuario inválido sin email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "usuario inválido sin nombre" do
    @user.firstname = nil
    assert_not @user.valid?
  end

  test "usuario inválido sin contraseña" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "usuario inválido si el email ya está tomado" do
    @user.save!
    duplicado = User.new(
      firstname: "Ana",
      lastname: "Pérez",
      email: @user.email,
      password: "password123",
      rol: "paciente"
    )
    assert_not duplicado.valid?
  end

  # -------------------------------
  # Métodos de rol
  # -------------------------------
  test "paciente? devuelve true cuando el rol es paciente" do
    assert @user.paciente?
  end

  test "doctor? devuelve true cuando el rol es doctor" do
    @user.rol = "doctor"
    assert @user.doctor?
  end

  test "admin? devuelve true cuando el rol es admin" do
    @user.rol = "admin"
    assert @user.admin?
  end

  test "paciente? devuelve false cuando el rol no es paciente" do
    @user.rol = "doctor"
    assert_not @user.paciente?
  end

  # -------------------------------
  # Método de nombre completo
  # -------------------------------
  test "nombre_completo concatena firstname y lastname" do
    assert_equal "Ana Pérez", @user.nombre_completo
  end

  test "nombre_completo maneja nombres nulos" do
    @user.firstname = nil
    @user.lastname = "SinNombre"
    assert_equal " SinNombre", @user.nombre_completo
  end

  # -------------------------------
  # Scope de doctores
  # -------------------------------
  test "scope doctores devuelve solo usuarios con rol doctor" do
    User.create!(
      firstname: "Dr",
      lastname: "House",
      email: "doctor_#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      rol: "doctor"
    )
    User.create!(
      firstname: "Carlos",
      lastname: "Paciente",
      email: "paciente_#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      rol: "paciente"
    )

    doctores = User.doctores
    assert_equal 1, doctores.count
    assert_equal "doctor", doctores.first.rol
  end

  # -------------------------------
  # Relaciones con reservas y reseñas
  # -------------------------------
  test "usuario puede tener muchas reservas como paciente y doctor" do
    @user.save!
    doctor = User.create!(
      firstname: "Dr",
      lastname: "Médico",
      email: "dr_#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      rol: "doctor"
    )
    Reserva.create!(
      paciente: @user,
      doctor: doctor,
      motivo: "Chequeo general",
      ubicacion: "Clínica Central",
      duracion: 30
    )
    Reserva.create!(
      paciente: @user,
      doctor: doctor,
      motivo: "Control anual",
      ubicacion: "Centro Médico",
      duracion: 45
    )
    assert_equal 2, @user.reservas_paciente.count
  end

  test "usuario puede tener reseñas asociadas" do
    @user.save!
    reserva = Reserva.create!(
      paciente: @user,
      doctor: User.create!(
        firstname: "Dr",
        lastname: "Smith",
        email: "smith_#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        rol: "doctor"
      ),
      motivo: "Consulta",
      ubicacion: "Hospital",
      duracion: 40
    )

    resena = Resena.create!(
      reserva: reserva,
      autor: @user,
      rating: 5,
      comment: "Excelente servicio"
    )
    assert_equal 1, @user.resenas.count
    assert_equal resena, @user.resenas.first
  end
end
