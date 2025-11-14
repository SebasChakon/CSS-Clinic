require 'net/http'
require 'uri'
require 'json'

class NominatimService
  BASE_URL = 'https://nominatim.openstreetmap.org/search'

  def self.buscar_farmacias(latitud, longitud, radio_km = 20)
    lat = latitud.to_f
    lng = longitud.to_f
    return [] if lat.zero? || lng.zero?
    buscar_y_filtrar_localmente(lat, lng, radio_km)
  end

  def self.buscar_y_filtrar_localmente(latitud, longitud, radio_km)
    params = {
      q: 'farmacia',
      format: 'json',
      lat: latitud,
      lon: longitud,
      limit: 20,
      countrycodes: 'cl',
      addressdetails: 1
    }

    begin
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = 'CSSClinicMedicalApp/1.0'
      request['Accept'] = 'application/json'
      
      sleep(1)
      response = http.request(request)
      
      if response.code == '200'
        resultados = JSON.parse(response.body)
        resultados_filtrados = filtrar_por_distancia(resultados, latitud, longitud, radio_km)
        parsear_resultados_solo_nombres_comerciales(resultados_filtrados)
      end
    end
  end

  private

  def self.filtrar_por_distancia(resultados, lat_central, lng_central, radio_km)
    resultados.select do |resultado|
      lat_resultado = resultado['lat'].to_f
      lng_resultado = resultado['lon'].to_f
      
      distancia = calcular_distancia_km(lat_central, lng_central, lat_resultado, lng_resultado)
      distancia <= radio_km
    end
  end

  def self.calcular_distancia_km(lat1, lon1, lat2, lon2)
    # Fórmula calcular distancia en kilómetros
    rad_per_deg = Math::PI / 180
    rkm = 6371 # Radio de la tierra

    dlat_rad = (lat2 - lat1) * rad_per_deg
    dlon_rad = (lon2 - lon1) * rad_per_deg

    lat1_rad = lat1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin(Math.sqrt(a))

    (rkm * c).round(2)
  end

  def self.parsear_resultados_solo_nombres_comerciales(resultados)
    farmacias_mejoradas = resultados.map do |resultado|
      direccion = resultado['display_name'].to_s.downcase
      nombre_original = resultado['name'].to_s
      nombre_comercial = detectar_solo_nombre_comercial(direccion, nombre_original)
      {
        'nombre' => nombre_comercial,
        'direccion' => resultado['display_name'].to_s,
        'latitud' => resultado['lat'].to_f,
        'longitud' => resultado['lon'].to_f
      }
    end.first(6) 
    farmacias_mejoradas
  end

  def self.detectar_solo_nombre_comercial(direccion, nombre_original)
    direccion_down = direccion.downcase
    nombre_down = nombre_original.downcase
    case
    when direccion_down.include?('ahumada') || nombre_down.include?('ahumada')
      'Farmacia Ahumada'
    when direccion_down.include?('cruz verde') || nombre_down.include?('cruz verde')
      'Farmacia Cruz Verde'
    when direccion_down.include?('salcobrand') || nombre_down.include?('salcobrand')
      'Farmacia Salcobrand'
    when direccion_down.include?('dr. simi') || direccion_down.include?('dr simi') || nombre_down.include?('simi')
      'Farmacia Dr. Simi'
    when direccion_down.include?('farmacia') && nombre_original.present?
      nombre_original
    else
      nombre_original.present? ? nombre_original : 'Farmacia'
    end
  end
end