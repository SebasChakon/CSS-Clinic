# frozen_string_literal: true

class ResenasControllerTest < ActionDispatch::IntegrationTest
  def setup
    uid = SecureRandom.hex(4)

    @paciente = User.create!(
      firstname: 'Ana',
      lastname: 'López',
      username: "anita#{uid}",
      email: "ana#{uid}@example.com",
      password: 'password',
      rol: :paciente,
      phone: 12_345_678
    )

    @otro_paciente = User.create!(
      firstname: 'Laura',
      lastname: 'Mejía',
      username: "lau#{uid}",
      email: "lau#{uid}@example.com",
      password: 'password',
      rol: :paciente,
      phone: 11_111_111
    )

    @doctor = User.create!(
      firstname: 'Carlos',
      lastname: 'Mora',
      username: "carlos#{uid}",
      email: "carlos#{uid}@example.com",
      password: 'password',
      rol: :doctor,
      phone: 87_654_321
    )

    @reserva_pasada = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: Time.current - 2.days,
      motivo: 'Chequeo general',
      ubicacion: 'Clínica Central',
      duracion: 45
    )

    @reserva_futura = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: Time.current + 2.days,
      motivo: 'Control',
      ubicacion: 'Clínica Norte',
      duracion: 30
    )

    @resena = Resena.create!(
      reserva: @reserva_pasada,
      autor: @paciente,
      rating: 5,
      comment: 'Excelente atención'
    )

    sign_in @paciente
  end

  test 'no debería permitir crear una reseña para una cita futura' do
    get new_reserva_resena_url(@reserva_futura)
    assert_redirected_to reserva_path(@reserva_futura)
    assert_equal 'No puedes reseñar una cita que aún no ha ocurrido.', flash[:alert]
  end

  test 'no debería permitir nueva reseña si el paciente ya reseñó' do
    get new_reserva_resena_url(@reserva_pasada)
    assert_redirected_to reserva_path(@reserva_pasada)
    assert_equal 'Ya dejaste una reseña para esta cita.', flash[:alert]
  end

  test 'solo el paciente de la reserva puede crear reseña' do
    sign_in @otro_paciente
    get new_reserva_resena_url(@reserva_pasada)
    assert_redirected_to reserva_path(@reserva_pasada)
    assert_equal 'Solo el paciente puede dejar una reseña.', flash[:alert]
  end

  test 'debería crear reseña válida correctamente' do
    @resena.destroy
    assert_difference('Resena.count', 1) do
      post reserva_resenas_url(@reserva_pasada), params: {
        resena: { rating: 4, comment: 'Muy buena atención' }
      }
    end
    assert_redirected_to reserva_path(@reserva_pasada)
    assert_equal 'Gracias — tu reseña fue publicada.', flash[:notice]
  end

  test 'no debería crear reseña inválida' do
    assert_no_difference('Resena.count') do
      post reserva_resenas_url(@reserva_pasada), params: {
        resena: { rating: nil, comment: 'Sin calificación' }
      }
    end
    assert_response :unprocessable_content
  end

  test 'debería actualizar reseña correctamente' do
    patch reserva_resena_url(@reserva_pasada, @resena), params: {
      resena: { rating: 4, comment: 'Buena atención, pero con demora' }
    }
    assert_redirected_to reserva_path(@reserva_pasada)
    assert_equal 'Reseña actualizada.', flash[:notice]
    @resena.reload
    assert_equal 4, @resena.rating
  end

  test 'no debería actualizar reseña inválida' do
    patch reserva_resena_url(@reserva_pasada, @resena), params: {
      resena: { rating: 10 }
    }
    assert_response :unprocessable_content
  end

  test 'autor puede eliminar su reseña' do
    assert_difference('Resena.count', -1) do
      delete reserva_resena_url(@reserva_pasada, @resena)
    end
    assert_redirected_to reserva_path(@reserva_pasada)
    assert_equal 'Reseña eliminada.', flash[:notice]
  end

  test 'otro usuario no puede eliminar reseña ajena' do
    sign_in @otro_paciente
    assert_no_difference('Resena.count') do
      delete reserva_resena_url(@reserva_pasada, @resena)
    end
    assert_redirected_to reserva_path(@reserva_pasada)
    assert_equal 'No tienes permiso para editar/eliminar esta reseña.', flash[:alert]
  end
end
