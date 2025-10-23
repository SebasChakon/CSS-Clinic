class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :reservas_paciente, class_name: 'Reserva', foreign_key: 'paciente_id'
  has_many :reservas_doctor, class_name: 'Reserva', foreign_key: 'doctor_id'
  has_many :resenas, foreign_key: 'autor_id', dependent: :nullify
  has_many :horario_atencions, foreign_key: 'doctor_id', dependent: :destroy

  has_one_attached :avatar

  enum rol: { paciente: 0, doctor: 1, admin: 2 }

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :username, presence: true
  validates :phone, presence: true

  def paciente?
    rol == 'paciente'
  end

  def doctor?
    rol == 'doctor'
  end

  def admin?
    rol == 'admin'
  end

  def nombre_completo
    "#{firstname} #{lastname}"
  end

  scope :doctores, -> { where(rol: :doctor) }
end
