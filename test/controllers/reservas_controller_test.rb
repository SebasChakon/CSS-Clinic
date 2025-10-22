require "test_helper"

class ReservasControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    uid = SecureRandom.hex(4)
  
    @paciente = User.create!(
      firstname: "María",
      lastname: "González",
      username: "maria#{uid}",
      email: "maria#{uid}@example.com",
      password: "password123",
      rol: :paciente,
      phone: 11111111
    )

    @doctor = User.create!(
      firstname: "Dr. Juan",
      lastname: "Pérez",
      username: "drjuan#{uid}",
      email: "drjuan#{uid}@example.com",
      password: "password123",
      rol: :doctor,
      phone: 22222222
    )

    @admin = User.create!(
      firstname: "Admin",
      lastname: "Sistema",
      username: "admin#{uid}",
      email: "admin#{uid}@example.com",
      password: "password123",
      rol: :admin,
      phone: 33333333
    )

    @reserva_pendiente = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: 3.days.from_now,
      motivo: "Consulta general",
      ubicacion: "Consultorio A",
      duracion: 30,
      estado: :pendiente
    )

    @reserva_confirmada = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: 5.days.from_now,
      motivo: "Control",
      ubicacion: "Consultorio B",
      duracion: 45,
      estado: :confirmada
    )

    @reserva_completada = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: 2.days.ago,
      motivo: "Revisión",
      ubicacion: "Consultorio C",
      duracion: 60,
      estado: :completada,
      notas: "Todo bien"
    )

    @reserva_cancelada = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: 1.day.from_now,
      motivo: "Emergencia",
      ubicacion: "Consultorio D",
      duracion: 30,
      estado: :cancelada
    )

    @resena = Resena.create!(
      reserva: @reserva_completada,
      autor: @paciente,
      rating: 5,
      comment: "Excelente atención"
    )
  end

  test "paciente puede ver su lista de reservas" do
    sign_in @paciente
    get reservas_url
    assert_response :success
    assert_includes @response.body, @reserva_pendiente.motivo
  end

  test "admin puede ver todas las reservas" do
    sign_in @admin
    get reservas_url
    assert_response :success
  end

  test "paciente puede filtrar reservas pendientes" do
    sign_in @paciente
    get reservas_url, params: { filtro: 'pendientes' }
    assert_response :success
  end

  test "paciente puede filtrar reservas confirmadas" do
    sign_in @paciente
    get reservas_url, params: { filtro: 'confirmadas' }
    assert_response :success
  end

  test "paciente puede filtrar reservas canceladas" do
    sign_in @paciente
    get reservas_url, params: { filtro: 'canceladas' }
    assert_response :success
  end

  test "paciente puede filtrar reservas completadas" do
    sign_in @paciente
    get reservas_url, params: { filtro: 'completadas' }
    assert_response :success
  end

  test "doctor puede filtrar próximas reservas" do
    sign_in @doctor
    get reservas_url, params: { filtro: 'proximas' }
    assert_response :success
  end

  test "doctor puede filtrar reservas pasadas" do
    sign_in @doctor
    get reservas_url, params: { filtro: 'pasadas' }
    assert_response :success
  end
  
  test "paciente puede ver el detalle de su reserva" do
    sign_in @paciente
    get reserva_url(@reserva_pendiente)
    assert_response :success
  end

  test "doctor puede ver el detalle de su reserva" do
    sign_in @doctor
    get reserva_url(@reserva_pendiente)
    assert_response :success
  end

  test "admin puede ver el detalle de cualquier reserva" do
    sign_in @admin
    get reserva_url(@reserva_pendiente)
    assert_response :success
  end

  test "doctor puede acceder al formulario de edición" do
    sign_in @doctor
    get edit_reserva_url(@reserva_pendiente)
    assert_response :success
  end

  test "paciente no puede acceder al formulario de edición" do
    sign_in @paciente
    get edit_reserva_url(@reserva_pendiente)
    assert_redirected_to reservas_path
    assert_equal 'No tienes permisos para editar esta reserva', flash[:alert]
  end

  test "doctor no puede editar reserva cancelada" do
    sign_in @doctor
    get edit_reserva_url(@reserva_cancelada)
    assert_redirected_to reserva_path(@reserva_cancelada)
    assert_equal 'No se pueden editar notas de una cita cancelada', flash[:alert]
  end

  test "doctor puede actualizar notas de una reserva" do
    sign_in @doctor
    patch reserva_url(@reserva_pendiente), params: {
      reserva: { notas: "Paciente requiere seguimiento" }
    }
    assert_redirected_to reserva_path(@reserva_pendiente)
    @reserva_pendiente.reload
    assert_equal "Paciente requiere seguimiento", @reserva_pendiente.notas
  end

  test "paciente no puede actualizar reserva" do
    sign_in @paciente
    patch reserva_url(@reserva_pendiente), params: {
      reserva: { notas: "Intento de actualización" }
    }
    assert_redirected_to reservas_path
    assert_equal 'No tienes permisos para editar esta reserva', flash[:alert]
  end

  test "doctor no puede actualizar reserva cancelada" do
    sign_in @doctor
    patch reserva_url(@reserva_cancelada), params: {
      reserva: { notas: "Nueva nota" }
    }
    assert_redirected_to reserva_path(@reserva_cancelada)
    assert_equal 'No se pueden editar notas de una cita cancelada', flash[:alert]
  end

  test "doctor puede confirmar una reserva pendiente" do
    sign_in @doctor
    get confirmar_reserva_url(@reserva_pendiente)
    assert_redirected_to reserva_path(@reserva_pendiente)
    @reserva_pendiente.reload
    assert_equal "confirmada", @reserva_pendiente.estado
    assert_equal 'Reserva confirmada exitosamente.', flash[:notice]
  end

  test "paciente no puede confirmar una reserva" do
    sign_in @paciente
    get confirmar_reserva_url(@reserva_pendiente)
    assert_redirected_to reservas_path
    assert_equal 'Solo los médicos pueden confirmar reservas', flash[:alert]
  end

  test "doctor puede completar una reserva" do
    sign_in @doctor
    get completar_reserva_url(@reserva_confirmada)
    assert_redirected_to reserva_path(@reserva_confirmada)
    @reserva_confirmada.reload
    assert_equal "completada", @reserva_confirmada.estado
    assert_equal 'Reserva marcada como completada.', flash[:notice]
  end

  test "paciente no puede completar una reserva" do
    sign_in @paciente
    get completar_reserva_url(@reserva_confirmada)
    assert_redirected_to reservas_path
    assert_equal 'Solo los médicos pueden marcar reservas como completadas', flash[:alert]
  end

  test "paciente puede cancelar su reserva" do
    sign_in @paciente
    get cancelar_reserva_url(@reserva_pendiente)
    assert_redirected_to reserva_path(@reserva_pendiente)
    @reserva_pendiente.reload
    assert_equal "cancelada", @reserva_pendiente.estado
    assert_equal 'Reserva cancelada exitosamente.', flash[:notice]
  end

  test "doctor puede cancelar una reserva" do
    sign_in @doctor
    reserva = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: 10.days.from_now,
      motivo: "Nueva consulta",
      ubicacion: "Consultorio E",
      duracion: 30,
      estado: :pendiente
    )
    
    get cancelar_reserva_url(reserva)
    assert_redirected_to reserva_path(reserva)
    reserva.reload
    assert_equal "cancelada", reserva.estado
  end

  test "usuario no autenticado no puede acceder a index" do
    get reservas_url
    assert_redirected_to new_user_session_path
  end

  test "usuario no autenticado no puede ver una reserva" do
    get reserva_url(@reserva_pendiente)
    assert_redirected_to new_user_session_path
  end

  test "admin puede filtrar reservas pendientes" do
    sign_in @admin
    get reservas_url, params: { filtro: 'pendientes' }
    assert_response :success
  end

  test "admin puede filtrar reservas confirmadas" do
    sign_in @admin
    get reservas_url, params: { filtro: 'confirmadas' }
    assert_response :success
  end

  test "admin puede filtrar reservas canceladas" do
    sign_in @admin
    get reservas_url, params: { filtro: 'canceladas' }
    assert_response :success
  end

  test "admin puede filtrar reservas completadas" do
    sign_in @admin
    get reservas_url, params: { filtro: 'completadas' }
    assert_response :success
  end

  test "doctor puede filtrar reservas pendientes" do
    sign_in @doctor
    get reservas_url, params: { filtro: 'pendientes' }
    assert_response :success
  end

  test "doctor puede filtrar reservas confirmadas" do
    sign_in @doctor
    get reservas_url, params: { filtro: 'confirmadas' }
    assert_response :success
  end

  test "doctor puede filtrar reservas canceladas" do
    sign_in @doctor
    get reservas_url, params: { filtro: 'canceladas' }
    assert_response :success
  end

  test "doctor puede filtrar reservas completadas" do
    sign_in @doctor
    get reservas_url, params: { filtro: 'completadas' }
    assert_response :success
  end
end