# db/seeds.rb
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

# 1. Reserva pendiente (mañana)
Reserva.create!(
  paciente: paciente,
  doctor: doctor,
  fecha_hora: DateTime.now + 1.day,
  motivo: "Consulta general de rutina", 
  estado: "pendiente",
  duracion: 30,
  ubicacion: "Consultorio Principal",
  notas: "Paciente viene por chequeo anual"
)

# 2. Reserva confirmada (pasado mañana)
Reserva.create!(
  paciente: paciente,
  doctor: doctor, 
  fecha_hora: DateTime.now + 2.days,
  motivo: "Seguimiento de tratamiento",
  estado: "confirmada",
  duracion: 45,
  ubicacion: "Consultorio Piso 2",
  notas: "Control de medicación mensual"
)

# 3. Reserva completada (ayer)
Reserva.create!(
  paciente: paciente,
  doctor: doctor,
  fecha_hora: DateTime.now - 1.day, 
  motivo: "Dolor de espalda",
  estado: "completada",
  duracion: 60,  
  ubicacion: "Consultorio Principal",
  notas: "Se recetó antiinflamatorios y reposo. Seguimiento en 2 semanas."
)

# 4. Reserva cancelada (la semana pasada)
Reserva.create!(
  paciente: paciente,
  doctor: doctor,
  fecha_hora: DateTime.now - 3.days,
  motivo: "Tos persistente",
  estado: "cancelada",
  duracion: 30,
  ubicacion: "Consultorio Piso 2",
  notas: "Paciente reportó mejoría y no asistió"
)

# 5. Reserva muy próxima (en 2 horas)
Reserva.create!(
  paciente: paciente,
  doctor: doctor,
  fecha_hora: DateTime.now + 2.hours,
  motivo: "Urgencia respiratoria",
  estado: "confirmada", 
  duracion: 90,
  ubicacion: "Urgencias",
  notas: "Paciente reporta dificultad para respirar"
)

puts "✅ ¡Reservas creadas exitosamente!"