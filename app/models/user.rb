class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Relaciones con reservas
  has_many :reservas_paciente, class_name: 'Reserva', foreign_key: 'paciente_id'

  def nombre_completo
    "#{firstname} #{lastname}"
  end
end
