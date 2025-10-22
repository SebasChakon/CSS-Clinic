# app/helpers/reservas_helper.rb
module ReservasHelper
  def estado_badge_class(estado)
    case estado.to_sym
    when :pendiente
      'bg-yellow-100 text-yellow-800'
    when :confirmada
      'bg-blue-100 text-blue-800'
    when :cancelada
      'bg-red-100 text-red-800'
    when :completada
      'bg-green-100 text-green-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end