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

    @paciente = User.create!(
      firstname: 'Juan',
      lastname: 'Pérez',
      username: "juanp#{uid}",
      email: "juanp#{uid}@example.com",
      password: 'password123',
      rol: :paciente,
      phone: 44_444_444
    )

    @admin = User.create!(
      firstname: 'Admin',
      lastname: 'Sistema',
      username: "admin#{uid}",
      email: "admin#{uid}@example.com",
      password: 'password123',
      rol: :admin,
      phone: 55_555_555
    )

    @horario_futuro = HorarioAtencion.create!(
      doctor: @doctor,
      fecha: 3.days.from_now.to_date,
      hora_inicio: Time.zone.parse('09:00'),
      hora_fin: Time.zone.parse('12:00'),
      ubicacion: 'Consultorio A',
      disponible: true
    )

    @horario_pasado = HorarioAtencion.new(
      doctor: @doctor,
      fecha: 3.days.ago.to_date,
      hora_inicio: Time.zone.parse('09:00'),
      hora_fin: Time.zone.parse('12:00'),
      ubicacion: 'Consultorio B',
      disponible: false
    )
    @horario_pasado.save!(validate: false)

    @horario_otro_doctor = HorarioAtencion.create!(
      doctor: @otro_doctor,
      fecha: 5.days.from_now.to_date,
      hora_inicio: Time.zone.parse('14:00'),
      hora_fin: Time.zone.parse('17:00'),
      ubicacion: 'Consultorio C',
      disponible: true
    )
  end

  test 'index requiere autenticación' do
    get horarios_url
    assert_redirected_to new_user_session_path
  end

  test 'doctor puede ver index de horarios' do
    sign_in @doctor
    get horarios_url
    assert_response :success
  end

  test 'admin puede ver index de horarios' do
    sign_in @admin
    get horarios_url
    assert_response :success
  end

  test 'index muestra solo horarios del doctor logueado' do
    sign_in @doctor
    get horarios_url
    assert_response :success
    assert_includes response.body, @horario_futuro.ubicacion
    assert_not_includes response.body, @horario_otro_doctor.ubicacion
  end

  test 'admin puede ver horarios de todos los doctores' do
    sign_in @admin
    get horarios_url
    assert_response :success
  end

  test 'new requiere autenticación' do
    get new_horario_url
    assert_redirected_to new_user_session_path
  end

  test 'doctor puede acceder al formulario de nuevo horario' do
    sign_in @doctor
    get new_horario_url
    assert_response :success
  end

  test 'paciente no puede acceder al formulario de nuevo horario' do
    sign_in @paciente
    get new_horario_url
    assert_response :redirect
  end

  test 'create requiere autenticación' do
    assert_no_difference('HorarioAtencion.count') do
      post horarios_url, params: {
        horario_atencion: {
          fecha: 7.days.from_now.to_date,
          hora_inicio: Time.zone.parse('09:00'),
          hora_fin: Time.zone.parse('12:00'),
          ubicacion: 'Consultorio Z'
        }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test 'horario creado se asocia automáticamente al doctor logueado' do
    sign_in @doctor
    post horarios_url, params: {
      horario_atencion: {
        fecha: 7.days.from_now.to_date,
        hora_inicio: Time.zone.parse('09:00'),
        hora_fin: Time.zone.parse('12:00'),
        ubicacion: 'Consultorio Z'
      }
    }
    nuevo_horario = HorarioAtencion.last
    assert_equal @doctor.id, nuevo_horario.doctor_id
  end

  test 'horario creado tiene disponible en true por defecto' do
    sign_in @doctor
    post horarios_url, params: {
      horario_atencion: {
        fecha: 7.days.from_now.to_date,
        hora_inicio: Time.zone.parse('09:00'),
        hora_fin: Time.zone.parse('12:00'),
        ubicacion: 'Consultorio Z'
      }
    }
    nuevo_horario = HorarioAtencion.last
    assert nuevo_horario.disponible
  end

  test 'se puede crear horario en misma fecha sin solapamiento' do
    sign_in @doctor
    assert_difference('HorarioAtencion.count', 1) do
      post horarios_url, params: {
        horario_atencion: {
          fecha: @horario_futuro.fecha,
          hora_inicio: Time.zone.parse('14:00'),
          hora_fin: Time.zone.parse('17:00'),
          ubicacion: 'Consultorio Z'
        }
      }
    end
    assert_redirected_to horarios_url
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

  test 'edit requiere autenticación' do
    get edit_horario_url(@horario_futuro)
    assert_redirected_to new_user_session_path
  end

  test 'doctor puede acceder a editar su propio horario' do
    sign_in @doctor
    get edit_horario_url(@horario_futuro)
    assert_response :success
  end

  test 'update requiere autenticación' do
    patch horario_url(@horario_futuro), params: {
      horario_atencion: {
        ubicacion: 'Nueva Ubicación'
      }
    }
    assert_redirected_to new_user_session_path
  end

  test 'doctor puede actualizar su propio horario' do
    sign_in @doctor
    patch horario_url(@horario_futuro), params: {
      horario_atencion: {
        ubicacion: 'Consultorio Actualizado'
      }
    }
    assert_redirected_to horarios_url
    @horario_futuro.reload
    assert_equal 'Consultorio Actualizado', @horario_futuro.ubicacion
  end

  test 'doctor no puede actualizar horario con datos inválidos' do
    sign_in @doctor
    patch horario_url(@horario_futuro), params: {
      horario_atencion: {
        fecha: nil
      }
    }
    assert_response :success
    @horario_futuro.reload
    assert_not_nil @horario_futuro.fecha
  end

  test 'se puede actualizar horario sin crear solapamiento' do
    sign_in @doctor
    patch horario_url(@horario_futuro), params: {
      horario_atencion: {
        hora_inicio: Time.zone.parse('08:00'),
        hora_fin: Time.zone.parse('11:00')
      }
    }
    assert_redirected_to horarios_url
    @horario_futuro.reload
    assert_equal '08:00', @horario_futuro.hora_inicio.strftime('%H:%M')
  end

  test 'destroy requiere autenticación' do
    assert_no_difference('HorarioAtencion.count') do
      delete horario_url(@horario_futuro)
    end
    assert_redirected_to new_user_session_path
  end

  test 'doctor puede eliminar su propio horario' do
    sign_in @doctor
    assert_difference('HorarioAtencion.count', -1) do
      delete horario_url(@horario_futuro)
    end
    assert_redirected_to horarios_url
  end
  
  test 'eliminación de horario es permanente' do
    sign_in @doctor
    horario_id = @horario_futuro.id
    delete horario_url(@horario_futuro)
    assert_nil HorarioAtencion.find_by(id: horario_id)
  end

  test 'doctor puede filtrar horarios por fecha' do
    sign_in @doctor
    get horarios_url, params: { fecha: @horario_futuro.fecha }
    assert_response :success
  end

  test 'doctor puede filtrar horarios disponibles' do
    sign_in @doctor
    get horarios_url, params: { disponible: true }
    assert_response :success
  end

  test 'crear horario con duración exacta de 15 minutos es válido' do
    sign_in @doctor
    assert_difference('HorarioAtencion.count', 1) do
      post horarios_url, params: {
        horario_atencion: {
          fecha: 7.days.from_now.to_date,
          hora_inicio: Time.zone.parse('09:00'),
          hora_fin: Time.zone.parse('09:15'),
          ubicacion: 'Consultorio Z'
        }
      }
    end
    assert_redirected_to horarios_url
  end

  test 'crear múltiples horarios no solapados en mismo día' do
    sign_in @doctor
    post horarios_url, params: {
      horario_atencion: {
        fecha: 10.days.from_now.to_date,
        hora_inicio: Time.zone.parse('08:00'),
        hora_fin: Time.zone.parse('10:00'),
        ubicacion: 'Consultorio Mañana'
      }
    }
    
    assert_difference('HorarioAtencion.count', 1) do
      post horarios_url, params: {
        horario_atencion: {
          fecha: 10.days.from_now.to_date,
          hora_inicio: Time.zone.parse('14:00'),
          hora_fin: Time.zone.parse('17:00'),
          ubicacion: 'Consultorio Tarde'
        }
      }
    end
    assert_redirected_to horarios_url
  end
  
  test 'doctor no puede actualizar horario de otro doctor' do
    sign_in @doctor
    patch horario_url(@horario_otro_doctor), params: {
      horario_atencion: { ubicacion: 'Hackeado' }
    }
    @horario_otro_doctor.reload
    assert_not_equal 'Hackeado', @horario_otro_doctor.ubicacion
  end

  test 'doctor no puede eliminar horario de otro doctor' do
    sign_in @doctor
    assert_no_difference('HorarioAtencion.count') do
      delete horario_url(@horario_otro_doctor)
    end
  end

  test 'no crea horario con hora_fin menor a hora_inicio' do
    sign_in @doctor
    assert_no_difference('HorarioAtencion.count') do
      post horarios_url, params: {
        horario_atencion: {
          fecha: 5.days.from_now.to_date,
          hora_inicio: Time.zone.parse('12:00'),
          hora_fin: Time.zone.parse('09:00'),
          ubicacion: 'Consultorio X'
        }
      }
    end
    assert_response :success
  end

  test 'no crea horario con fecha pasada' do
    sign_in @doctor
    assert_no_difference('HorarioAtencion.count') do
      post horarios_url, params: {
        horario_atencion: {
          fecha: 5.days.ago.to_date,
          hora_inicio: Time.zone.parse('09:00'),
          hora_fin: Time.zone.parse('11:00'),
          ubicacion: 'Consultorio Y'
        }
      }
    end
    assert_response :success
  end

  test 'filtro por fecha no muestra horarios de otros doctores' do
    sign_in @doctor
    get horarios_url, params: { fecha: @horario_otro_doctor.fecha }
    assert_response :success
    assert_not_includes response.body, @horario_otro_doctor.ubicacion
  end

  test 'filtro disponible=true solo muestra disponibles' do
    sign_in @doctor
    get horarios_url, params: { disponible: true }
    assert_response :success

    assert_includes response.body, @horario_futuro.ubicacion
    assert_not_includes response.body, @horario_pasado.ubicacion
  end

  test 'update no permite modificar doctor_id' do
    sign_in @doctor
    patch horario_url(@horario_futuro), params: {
      horario_atencion: {
        doctor_id: @otro_doctor.id,
        ubicacion: 'Consultorio X'
      }
    }

    @horario_futuro.reload
    assert_equal @doctor.id, @horario_futuro.doctor_id
  end

  test 'no crea horario con duración menor a 15 minutos' do
    sign_in @doctor
    assert_no_difference('HorarioAtencion.count') do
      post horarios_url, params: {
        horario_atencion: {
          fecha: 4.days.from_now.to_date,
          hora_inicio: Time.zone.parse('10:00'),
          hora_fin: Time.zone.parse('10:10'),
          ubicacion: 'Consultorio Rapidín'
        }
      }
    end
    assert_response :success
  end
end
