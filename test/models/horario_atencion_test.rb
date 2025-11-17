# frozen_string_literal: true

class HorarioAtencionTest < ActiveSupport::TestCase
  test 'nombre_dia retorna Domingo para domingo' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 16))
    assert_equal 'Domingo', horario.nombre_dia
  end

  test 'nombre_dia retorna Lunes para lunes' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 17))
    assert_equal 'Lunes', horario.nombre_dia
  end

  test 'nombre_dia retorna Martes para martes' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 18))
    assert_equal 'Martes', horario.nombre_dia
  end

  test 'nombre_dia retorna Miércoles para miércoles' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 19))
    assert_equal 'Miércoles', horario.nombre_dia
  end

  test 'nombre_dia retorna Jueves para jueves' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 13))
    assert_equal 'Jueves', horario.nombre_dia
  end

  test 'nombre_dia retorna Viernes para viernes' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 14))
    assert_equal 'Viernes', horario.nombre_dia
  end

  test 'nombre_dia retorna Sábado para sábado' do
    horario = HorarioAtencion.new(fecha: Date.new(2025, 11, 15))
    assert_equal 'Sábado', horario.nombre_dia
  end
end