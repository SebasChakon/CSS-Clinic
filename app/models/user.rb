class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :reservas_paciente, class_name: 'Reserva', foreign_key: 'paciente_id'
  has_many :reservas_doctor, class_name: 'Reserva', foreign_key: 'doctor_id'
  has_many :horario_atencions, foreign_key: 'doctor_id', dependent: :destroy

  enum rol: { paciente: 0, doctor: 1 }

  def paciente?
    rol == 'paciente'
  end

  def doctor?
    rol == 'doctor'
  end

  def nombre_completo
    "#{firstname} #{lastname}"
  end

  scope :doctores, -> { where(rol: :doctor) }
end
