# frozen_string_literal: true

Resena.destroy_all
Mensaje.destroy_all
Reserva.destroy_all
HorarioAtencion.destroy_all
User.destroy_all

admin = User.create!(
  email: 'admin@clinica.com',
  firstname: 'Administrador',
  lastname: 'Sistema',
  username: 'admin',
  phone: '+56911111111',
  rol: 'admin',
  password: '123456',
  password_confirmation: '123456'
)

doctores = []

doctores << User.create!(
  email: 'doctor@clinica.com',
  firstname: 'Juan',
  lastname: 'Vargas',
  username: 'doctor_juan',
  phone: '+56912345678',
  rol: 'doctor',
  password: '123456',
  password_confirmation: '123456'
)

doctores << User.create!(
  email: 'maria.silva@clinica.com',
  firstname: 'María',
  lastname: 'Silva',
  username: 'doctora_maria',
  phone: '+56923456789',
  rol: 'doctor',
  password: '123456',
  password_confirmation: '123456'
)

doctores << User.create!(
  email: 'carlos.rodriguez@clinica.com',
  firstname: 'Carlos',
  lastname: 'Rodríguez',
  username: 'doctor_carlos',
  phone: '+56934567890',
  rol: 'doctor',
  password: '123456',
  password_confirmation: '123456'
)

doctores << User.create!(
  email: 'patricia.gonzalez@clinica.com',
  firstname: 'Patricia',
  lastname: 'González',
  username: 'doctora_patricia',
  phone: '+56945678901',
  rol: 'doctor',
  password: '123456',
  password_confirmation: '123456'
)

doctores << User.create!(
  email: 'roberto.martinez@clinica.com',
  firstname: 'Roberto',
  lastname: 'Martínez',
  username: 'doctor_roberto',
  phone: '+56956789012',
  rol: 'doctor',
  password: '123456',
  password_confirmation: '123456'
)

pacientes = []

pacientes << User.create!(
  email: 'paciente@clinica.com',
  firstname: 'Isidora',
  lastname: 'Rojas',
  username: 'isidora_rojas',
  phone: '+56987654321',
  rol: 'paciente',
  password: '123456',
  password_confirmation: '123456'
)

pacientes << User.create!(
  email: 'pedro.castro@clinica.com',
  firstname: 'Pedro',
  lastname: 'Castro',
  username: 'pedro_castro',
  phone: '+56976543210',
  rol: 'paciente',
  password: '123456',
  password_confirmation: '123456'
)

pacientes << User.create!(
  email: 'lucia.fernandez@clinica.com',
  firstname: 'Lucía',
  lastname: 'Fernández',
  username: 'lucia_fernandez',
  phone: '+56965432109',
  rol: 'paciente',
  password: '123456',
  password_confirmation: '123456'
)

pacientes << User.create!(
  email: 'andres.morales@clinica.com',
  firstname: 'Andrés',
  lastname: 'Morales',
  username: 'andres_morales',
  phone: '+56954321098',
  rol: 'paciente',
  password: '123456',
  password_confirmation: '123456'
)

pacientes << User.create!(
  email: 'carolina.lopez@clinica.com',
  firstname: 'Carolina',
  lastname: 'López',
  username: 'carolina_lopez',
  phone: '+56943210987',
  rol: 'paciente',
  password: '123456',
  password_confirmation: '123456'
)

pacientes << User.create!(
  email: 'diego.munoz@clinica.com',
  firstname: 'Diego',
  lastname: 'Muñoz',
  username: 'diego_munoz',
  phone: '+56932109876',
  rol: 'paciente',
  password: '123456',
  password_confirmation: '123456'
)

horarios = []

doctores.each do |doctor|
  (0..9).each do |dia|
    fecha = Date.today + dia.days

    horarios << HorarioAtencion.create!(
      doctor: doctor,
      fecha: fecha,
      hora_inicio: Time.zone.parse("#{fecha} 09:00"),
      hora_fin: Time.zone.parse("#{fecha} 13:00"),
      ubicacion: "Consultorio #{doctor.id}, Piso 2",
      disponible: dia > 2 
    )

    if [1, 3, 5].include?(fecha.wday)
      horarios << HorarioAtencion.create!(
        doctor: doctor,
        fecha: fecha,
        hora_inicio: Time.zone.parse("#{fecha} 15:00"),
        hora_fin: Time.zone.parse("#{fecha} 18:00"),
        ubicacion: "Consultorio #{doctor.id}, Piso 2",
        disponible: true
      )
    end
  end
end

reservas = []

reservas << Reserva.create!(
  paciente: pacientes[0],
  doctor: doctores[0],
  fecha_hora: 3.days.ago,
  duracion: 30,
  motivo: 'Control general de salud',
  ubicacion: 'Consultorio 1, Piso 2',
  estado: 'completada'
)

reservas << Reserva.create!(
  paciente: pacientes[1],
  doctor: doctores[1],
  fecha_hora: 5.days.ago,
  duracion: 45,
  motivo: 'Consulta por dolor de cabeza persistente',
  ubicacion: 'Consultorio 2, Piso 2',
  estado: 'completada'
)

reservas << Reserva.create!(
  paciente: pacientes[2],
  doctor: doctores[2],
  fecha_hora: 7.days.ago,
  duracion: 30,
  motivo: 'Seguimiento de tratamiento',
  ubicacion: 'Consultorio 3, Piso 2',
  estado: 'completada'
)

reservas << Reserva.create!(
  paciente: pacientes[3],
  doctor: doctores[3],
  fecha_hora: 2.days.from_now.change(hour: 10),
  duracion: 30,
  motivo: 'Primera consulta - dolor articular',
  ubicacion: 'Consultorio 4, Piso 2',
  estado: 'confirmada'
)

reservas << Reserva.create!(
  paciente: pacientes[4],
  doctor: doctores[4],
  fecha_hora: 3.days.from_now.change(hour: 11),
  duracion: 60,
  motivo: 'Evaluación médica completa',
  ubicacion: 'Consultorio 5, Piso 2',
  estado: 'confirmada'
)

reservas << Reserva.create!(
  paciente: pacientes[5],
  doctor: doctores[0],
  fecha_hora: 4.days.from_now.change(hour: 9),
  duracion: 30,
  motivo: 'Consulta por síntomas gripales',
  ubicacion: 'Consultorio 1, Piso 2',
  estado: 'pendiente'
)

reservas << Reserva.create!(
  paciente: pacientes[0],
  doctor: doctores[2],
  fecha_hora: 5.days.from_now.change(hour: 15),
  duracion: 45,
  motivo: 'Control de presión arterial',
  ubicacion: 'Consultorio 3, Piso 2',
  estado: 'pendiente'
)

reservas << Reserva.create!(
  paciente: pacientes[1],
  doctor: doctores[1],
  fecha_hora: 1.day.from_now.change(hour: 16),
  duracion: 30,
  motivo: 'Consulta general',
  ubicacion: 'Consultorio 2, Piso 2',
  estado: 'cancelada'
)

mensajes = []

mensajes << Mensaje.create!(
  reserva: reservas[0],
  user: pacientes[0],
  contenido: 'Buenos días doctor, confirmo mi asistencia a la cita.'
)

mensajes << Mensaje.create!(
  reserva: reservas[0],
  user: doctores[0],
  contenido: 'Perfecto, le esperamos. Por favor llegue 10 minutos antes.'
)

mensajes << Mensaje.create!(
  reserva: reservas[0],
  user: pacientes[0],
  contenido: 'Entendido, muchas gracias.'
)

mensajes << Mensaje.create!(
  reserva: reservas[1],
  user: pacientes[1],
  contenido: '¿Necesito llevar algún examen previo?'
)

mensajes << Mensaje.create!(
  reserva: reservas[1],
  user: doctores[1],
  contenido: 'Si tiene exámenes anteriores sería útil, pero no es obligatorio.'
)

mensajes << Mensaje.create!(
  reserva: reservas[3],
  user: doctores[3],
  contenido: 'Su cita ha sido confirmada. Le recordamos traer su cédula de identidad.'
)

mensajes << Mensaje.create!(
  reserva: reservas[3],
  user: pacientes[3],
  contenido: 'Perfecto, ahí estaré. Gracias.'
)

mensajes << Mensaje.create!(
  reserva: reservas[5],
  user: pacientes[5],
  contenido: 'Solicito atención urgente por favor.'
)

resenas = []

resenas << Resena.create!(
  reserva: reservas[0],
  autor: pacientes[0],
  rating: 5,
  comment: 'Excelente atención, muy profesional y empático. Resolvió todas mis dudas.'
)

resenas << Resena.create!(
  reserva: reservas[1],
  autor: pacientes[1],
  rating: 4,
  comment: 'Muy buena atención, aunque tuve que esperar un poco más de lo programado.'
)

resenas << Resena.create!(
  reserva: reservas[2],
  autor: pacientes[2],
  rating: 5,
  comment: 'Doctor muy atento y dedicado. Me explicó todo detalladamente.'
)