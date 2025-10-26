# frozen_string_literal: true

require 'test_helper'

class HorariosControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    uid = SecureRandom.hex(4)

    @doctor = User.create!(
      firstname: 'Dra. Laura',
      lastname: 'Martínez',
      username: "dralau#{uid}",
      email: "dralau#{uid}@example.com",
      password: 'password123',
      rol: :doctor,
      phone: 22_222_222
    )

    @otro_doctor = User.create!(
      firstname: 'Dr. Roberto',
      lastname: 'Gómez',
      username: "drrob#{uid}",
      email: "drrob#{uid}@example.com",
      password: 'password123',
      rol: :doctor,
      phone: 33_333_333
    )

    @horario_futuro = HorarioAtencion.create!(
      doctor: @doctor,
      fecha: 3.days.from_now.to_date,
      hora_inicio: Time.zone.parse('09:00'),
      hora_fin: Time.zone.parse('12:00'),
      ubicacion: 'Consultorio A',
      disponible: true
    )
  end

  test 'doctor no puede actualizar horario con datos inválidos' do
    sign_in @doctor
    patch horario_url(@horario_futuro), params: {
      horario_atencion: {
        fecha: nil
      }
    }
    assert_response :success
  end

  test 'eliminación de horario es permanente' do
    sign_in @doctor
    horario_id = @horario_futuro.id
    delete horario_url(@horario_futuro)
    assert_nil HorarioAtencion.find_by(id: horario_id)
  end

  test 'solo se permiten los parámetros autorizados' do
    sign_in @doctor
    post horarios_url, params: {
      horario_atencion: {
        fecha: 17.days.from_now.to_date,
        hora_inicio: Time.zone.parse('09:00'),
        hora_fin: Time.zone.parse('12:00'),
        ubicacion: 'Consultorio Z',
        disponible: false,
        doctor_id: @otro_doctor.id
      }
    }

    nuevo_horario = HorarioAtencion.last
    assert_equal @doctor.id, nuevo_horario.doctor_id
    assert nuevo_horario.disponible
  end
end
