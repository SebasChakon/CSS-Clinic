require 'net/http'
require 'uri'
require 'json'

class NominatimService
  BASE_URL = 'https://nominatim.openstreetmap.org/search'

  def self.buscar_farmacias(latitud, longitud, radio_km = 3)
    lat = latitud.to_f
    lng = longitud.to_f
    return [] if lat.zero? || lng.zero?
    bbox = calcular_bounding_box(lat, lng, radio_km)
    resultados = buscar_con_bounding_box(bbox)
    
    # Filtrar por distancia real
    resultados_filtrados = filtrar_por_distancia_real(resultados, lat, lng, radio_km)
    parsear_resultados(resultados_filtrados)
  end

  def self.calcular_bounding_box(lat, lon, radio_km)
    offset = radio_km * 0.009
    left = lon - offset
    right = lon + offset  
    bottom = lat - offset
    top = lat + offset
    
    "#{left},#{bottom},#{right},#{top}"
  end

  def self.buscar_con_bounding_box(bbox)
    params = {
      q: 'farmacia',
      format: 'json',
      bounded: 1,
      viewbox: bbox,
      limit: 50,
      countrycodes: 'cl',
      addressdetails: 1
    }
    hacer_peticion(params)
  end

  def self.buscar_con_radio_directo(lat, lon, radio_km)
    params = {
      q: 'farmacia',
      format: 'json',
      lat: lat,
      lon: lon, 
      radius: radio_km * 1000,
      limit: 50,
      countrycodes: 'cl'
    }
    hacer_peticion(params)
  end

  def self.hacer_peticion(params)
    begin
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30
      request = Net::HTTP::Get.new(uri)
      request['User-Agent'] = 'MedicalApp/1.0 (contacto@ejemplo.com)'
      request['Accept'] = 'application/json'

      sleep(1)
      response = http.request(request)
      if response.code == '200'
        datos = JSON.parse(response.body)
        datos
      else
        puts "Error HTTP: #{response.code}"
        []
      end
    rescue => e
      puts "Error en petición: #{e.message}"
      []
    end
  end

  def self.filtrar_por_distancia_real(resultados, lat_central, lng_central, radio_km)
    resultados.select do |resultado|
      next false unless resultado['lat'] && resultado['lon']
      lat_resultado = resultado['lat'].to_f
      lng_resultado = resultado['lon'].to_f
      distancia = calcular_distancia_km(lat_central, lng_central, lat_resultado, lng_resultado)
      nombre = resultado['name'] || 'Sin nombre'
      
      distancia <= radio_km
    end.sort_by do |resultado|
      calcular_distancia_km(lat_central, lng_central, resultado['lat'].to_f, resultado['lon'].to_f)
    end
  end

  def self.calcular_distancia_km(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI / 180
    rkm = 6371

    dlat_rad = (lat2 - lat1) * rad_per_deg
    dlon_rad = (lon2 - lon1) * rad_per_deg

    lat1_rad = lat1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math.asin(Math.sqrt(a))

    (rkm * c).round(2)
  end

  def self.parsear_resultados(resultados)
    resultados.map do |resultado|
      nombre = mejorar_nombre_farmacia(resultado['name'], resultado['display_name'])
      direccion = resultado['display_name'] || 'Dirección no disponible'
      
      {
        'nombre' => nombre,
        'direccion' => direccion,
        'latitud' => resultado['lat'].to_f,
        'longitud' => resultado['lon'].to_f
      }
    end.first(6)
  end

  def self.mejorar_nombre_farmacia(nombre_original, direccion_completa)
    return 'Farmacia' if nombre_original.blank?
    nombre_down = nombre_original.downcase
    direccion_down = direccion_completa.downcase
    if nombre_down.include?('cruz verde') || direccion_down.include?('cruz verde')
      'Farmacia Cruz Verde'
    elsif nombre_down.include?('ahumada') || direccion_down.include?('ahumada')
      'Farmacia Ahumada'
    elsif nombre_down.include?('salcobrand') || direccion_down.include?('salcobrand')
      'Farmacia Salcobrand'
    elsif nombre_down.include?('simi') || direccion_down.include?('simi')
      'Farmacia Dr. Simi'
    elsif nombre_down.include?('farmacia')
      nombre_original
    else
      "Farmacia #{nombre_original}"
    end
  end
end