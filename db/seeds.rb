# frozen_string_literal: true

# Administrador
User.find_or_create_by!(
  email: 'admin@clinica.com',
  firstname: 'Administrador',
  lastname: 'Sistema',
  username: 'admin',
  phone: '+56911111111',
  rol: 'admin'
) do |user|
  user.password = '123456'
  user.password_confirmation = '123456'
  puts "Administrador creado: #{user.email}"
end

# Médico
User.find_or_create_by!(
  email: 'doctor@clinica.com',
  firstname: 'Juan',
  lastname: 'Vargas',
  username: 'doctor_juan',
  phone: '+56912345678',
  rol: 'doctor'
) do |user|
  user.password = '123456'
  user.password_confirmation = '123456'
  puts "Médico creado: #{user.email}"
end

# Paciente
User.find_or_create_by!(
  email: 'paciente@clinica.com',
  firstname: 'Isidora',
  lastname: 'Rojas',
  username: 'isidora_rojas',
  phone: '+56987654321',
  rol: 'paciente'
) do |user|
  user.password = '123456'
  user.password_confirmation = '123456'
  puts "Paciente creado: #{user.email}"
end
