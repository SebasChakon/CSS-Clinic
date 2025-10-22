class HorarioAtencion < ApplicationRecord
  belongs_to :doctor, class_name: 'User'

  enum dia_semana: {
    lunes: 0, martes: 1, miércoles: 2, jueves: 3, 
    viernes: 4, sábado: 5, domingo: 6
  }

  attribute :disponible, :boolean, default: true

  validates :dia_semana, presence: true
  validates :hora_inicio, presence: true
  validates :hora_fin, presence: true
  validates :doctor_id, presence: true
  validates :ubicacion, presence: true
  
  validate :hora_fin_mayor_a_inicio
  validate :duracion_minima
  validate :no_solapamiento_horarios

  scope :disponibles, -> { where(disponible: true) }
  scope :por_doctor, ->(doctor_id) { where(doctor_id: doctor_id) }
  scope :por_dia, ->(dia) { where(dia_semana: dia) }

  def self.dias_semana_options
    dia_semanas.keys.map { |d| [d.humanize, d] }
  end

  def duracion_cita
    return 0 unless hora_inicio.present? && hora_fin.present?
    ((hora_fin - hora_inicio) / 60).to_i
  end

  private

  def hora_fin_mayor_a_inicio
    return unless hora_inicio.present? && hora_fin.present?
    if hora_fin <= hora_inicio
      errors.add(:hora_fin, "debe ser mayor a la hora de inicio")
    end
  end

  def duracion_minima
    return unless hora_inicio.present? && hora_fin.present?
    
    duracion = duracion_cita
    if duracion < 15
      errors.add(:hora_fin, "la duración mínima debe ser de 15 minutos")
    end
  end

  def no_solapamiento_horarios
    return unless doctor_id.present? && dia_semana.present? && hora_inicio.present? && hora_fin.present?
    
    horarios_solapados = HorarioAtencion.where(doctor_id: doctor_id, dia_semana: dia_semana)
                                      .where.not(id: id)
                                      .where("(hora_inicio < ? AND hora_fin > ?) OR (hora_inicio < ? AND hora_fin > ?)", 
                                             hora_fin, hora_inicio, hora_inicio, hora_fin)
    
    if horarios_solapados.exists?
      errors.add(:base, "El horario se solapa con otro horario existente")
    end
  end
end