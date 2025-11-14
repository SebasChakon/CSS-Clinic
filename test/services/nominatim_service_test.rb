# frozen_string_literal: true

require 'test_helper'

class NominatimServiceTest < ActiveSupport::TestCase
  FAKE_RESPONSE = [
    { 'lat' => '-33.456', 'lon' => '-70.648', 'display_name' => 'Farmacia Ahumada, Santiago', 'name' => 'Ahumada' },
    { 'lat' => '-33.457', 'lon' => '-70.649', 'display_name' => 'Cruz Verde, Providencia', 'name' => 'Cruz Verde' },
    { 'lat' => '-33.458', 'lon' => '-70.650', 'display_name' => 'Salcobrand, Ñuñoa', 'name' => 'Salcobrand' },
    { 'lat' => '-33.459', 'lon' => '-70.651', 'display_name' => 'Dr Simi, La Florida', 'name' => 'Dr Simi' },
    { 'lat' => '-33.460', 'lon' => '-70.652', 'display_name' => 'Farmacia Central', 'name' => 'Central' },
    { 'lat' => '-33.461', 'lon' => '-70.653', 'display_name' => 'Farmacia 123', 'name' => '' },
    { 'lat' => '-33.462', 'lon' => '-70.654', 'display_name' => 'Extra fuera de límite', 'name' => 'Extra' }
  ].freeze

  setup do
    @lat = -33.45
    @lng = -70.65
  end

  test 'buscar_farmacias retorna vacío si latitud o longitud son 0' do
    assert_equal [], NominatimService.buscar_farmacias(0, -70.65)
    assert_equal [], NominatimService.buscar_farmacias(-33.45, 0)
  end

  test 'buscar_farmacias llama a buscar_y_filtrar_localmente con parámetros correctos' do
    NominatimService.stub(:buscar_y_filtrar_localmente, [:ok]) do
      assert_equal [:ok], NominatimService.buscar_farmacias(@lat, @lng, 50)
    end
  end

  test 'filtrar_por_distancia excluye elementos fuera del radio' do
    cerca = { 'lat' => '-33.456', 'lon' => '-70.648' }
    lejos = { 'lat' => '-33.900', 'lon' => '-71.300' }

    resultados = [cerca, lejos]

    filtrados = NominatimService.send(:filtrar_por_distancia, resultados, @lat, @lng, 5)
    assert_equal 1, filtrados.size
  end

  test 'parsear_resultados_solo_nombres_comerciales estructura los datos correctamente' do
    parsed = NominatimService.send(:parsear_resultados_solo_nombres_comerciales, FAKE_RESPONSE.first(2))

    assert_equal 2, parsed.size

    farmacia = parsed.first
    assert farmacia['nombre'].present?
    assert farmacia['latitud'].is_a?(Float)
    assert farmacia['longitud'].is_a?(Float)
    assert farmacia['direccion'].is_a?(String)
  end

  test 'detecta marca Farmacia Ahumada correctamente' do
    r = NominatimService.send(:detectar_solo_nombre_comercial, 'farmacia ahumada avenida', 'random')
    assert_equal 'Farmacia Ahumada', r
  end

  test 'detecta marca Cruz Verde correctamente' do
    r = NominatimService.send(:detectar_solo_nombre_comercial, 'algo cruz verde', 'none')
    assert_equal 'Farmacia Cruz Verde', r
  end

  test 'detecta marca Salcobrand correctamente' do
    r = NominatimService.send(:detectar_solo_nombre_comercial, 'local salcobrand central', '')
    assert_equal 'Farmacia Salcobrand', r
  end

  test 'detecta marca Dr. Simi correctamente' do
    r = NominatimService.send(:detectar_solo_nombre_comercial, 'aca dr. simi jajaja', '')
    assert_equal 'Farmacia Dr. Simi', r
  end

  test "si no hay nombre, pero display contiene 'farmacia', devuelve el nombre original" do
    r = NominatimService.send(:detectar_solo_nombre_comercial, 'farmacia central', 'Central')
    assert_equal 'Central', r
  end

  test "si no hay nombre original ni marca detectada, devuelve 'Farmacia'" do
    r = NominatimService.send(:detectar_solo_nombre_comercial, 'cualquier cosa', '')
    assert_equal 'Farmacia', r
  end
end
