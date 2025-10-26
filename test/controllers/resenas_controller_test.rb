# frozen_string_literal: true

require 'test_helper'

class ResenasControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

    @doctor = User.create!(
      firstname: 'Carlos',
      lastname: 'Mora',
      username: "carlos#{uid}",
      email: "carlos#{uid}@example.com",
      password: 'password',
      rol: :doctor,
      phone: 87_654_321
    )

    @reserva = Reserva.create!(
      paciente: @paciente,
      doctor: @doctor,
      fecha_hora: Time.current - 2.days,
      motivo: 'Chequeo general',
      ubicacion: 'Clínica Central',
      duracion: 45
    )

    @resena = Resena.create!(
      reserva: @reserva,
      autor: @paciente,
      rating: 5,
      comment: 'Excelente atención'
    )

    sign_in @paciente
  end

  test 'no debería crear reseña inválida' do
    assert_no_difference('Resena.count') do
      post reserva_resenas_url(@reserva), params: {
        resena: { rating: nil, comment: 'Sin calificación' }
      }
    end
    assert_response :unprocessable_content
  end

  test 'no debería actualizar reseña inválida' do
    patch reserva_resena_url(@reserva, @resena), params: {
      resena: { rating: 10 }
    }
    assert_response :unprocessable_content
  end
end
