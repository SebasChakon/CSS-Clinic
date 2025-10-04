class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Relaciones con reservas
  has_many :reservas_paciente, class_name: 'Reserva', foreign_key: 'paciente_id'
  has_many :reservas_doctor, class_name: 'Reserva', foreign_key: 'doctor_id'

  # Rol del usuario
  enum rol: { paciente: 0, doctor: 1 }

  # Métodos para verificar el rol
  def paciente?
    rol == 'paciente'
  end

  def doctor?
    rol == 'doctor'
  end

  def nombre_completo
    "#{firstname} #{lastname}"
  end

  # Scope para doctores
  scope :doctores, -> { where(rol: :doctor) }
end
