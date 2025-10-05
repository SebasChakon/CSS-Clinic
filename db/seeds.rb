puts "🌱 Iniciando reservas de pruebas..."

# Crear médico de prueba
doctor = User.find_or_create_by!(
  email: "doctor@clinica.com",
  firstname: "Dr. Roberto",
  lastname: "Méndez",
  phone: "+56912345678",
  rol: "doctor"
) do |user|
  user.password = "123456"
  user.password_confirmation = "123456"
  puts "Médico creado: #{user.email}"
end

# Crear paciente de prueba  
paciente = User.find_or_create_by!(
  email: "paciente@clinica.com", 
  firstname: "Martina",
  lastname: "García",
  phone: "+56987654321",
  rol: "paciente"
) do |user|
  user.password = "123456"
  user.password_confirmation = "123456"
  puts "Paciente creado: #{user.email}"
end

# Eliminar reservas existentes para evitar duplicados
Reserva.destroy_all
puts "Reservas anteriores eliminadas"

# Crear reservas de ejemplo para todos los estados
reservas = []

# 1. Reserva PENDIENTE (mañana)
reserva1 = Reserva.create!(
paciente: paciente,
doctor: doctor,
fecha_hora: DateTime.now + 1.day,
motivo: "Consulta general de rutina",
estado: "pendiente",
notas: "Paciente viene por chequeo anual"
)
reservas_creadas << reserva1

# Reserva confirmada (pasado mañana)
reserva2 = Reserva.create!(
paciente: paciente,
doctor: doctor,
fecha_hora: DateTime.now + 2.days,
motivo: "Seguimiento de tratamiento",
estado: "confirmada", 
notas: "Control de medicación mensual"
)
reservas_creadas << reserva2

# Reserva completada (ayer)
reserva3 = Reserva.create!(
paciente: paciente,
doctor: doctor,
fecha_hora: DateTime.now - 1.day,
motivo: "Dolor de espalda",
estado: "completada",
notas: "Se recetó antiinflamatorios y reposo. Seguimiento en 2 semanas."
)
reservas_creadas << reserva3

# Reserva cancelada (la semana pasada)
reserva4 = Reserva.create!(
paciente: paciente,
doctor: doctor,
fecha_hora: DateTime.now - 3.days,
motivo: "tos",
estado: "cancelada",
notas: "Paciente reportó mejoría y no asistió"
)
reservas_creadas << reserva4

# Reserva muy próxima (en 2 horas)
reserva5 = Reserva.create!(
paciente: paciente,
doctor: doctor,
fecha_hora: DateTime.now + 2.hours,
motivo: "Urgencia", 
estado: "confirmada",
notas: "Paciente reporta dificultad para respirar"
)
reservas_creadas << reserva5

puts "¡Seeds completados exitosamente!"
puts "Total de reservas creadas: #{reservas.size}"
puts ""
puts "Credenciales para testing:"
puts "   Médico: doctor@clinica.com / 123456"
puts "   Paciente: paciente@clinica.com / 123456"
puts ""
puts "Estados disponibles:"
puts "   - Pendiente: #{Reserva.pendiente.count}"
puts "   - Confirmada: #{Reserva.confirmada.count}" 
puts "   - Completada: #{Reserva.completada.count}"
puts "   - Cancelada: #{Reserva.cancelada.count}"