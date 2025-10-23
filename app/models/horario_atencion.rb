class HorarioAtencion < ApplicationRecord
  belongs_to :doctor, class_name: 'User'

  validates :fecha, presence: true
  validates :hora_inicio, presence: true
  validates :hora_fin, presence: true
  validates :doctor_id, presence: true
  validates :ubicacion, presence: true
  
  validate :fecha_no_pasada
  validate :hora_fin_mayor_a_inicio
  validate :duracion_minima
  validate :no_solapamiento_horarios

  scope :disponibles, -> { where(disponible: true) }
  scope :por_doctor, ->(doctor_id) { where(doctor_id: doctor_id) }
  scope :futuros, -> { where('fecha >= ?', Date.today) }
  scope :por_fecha, ->(fecha) { where(fecha: fecha) }

  attribute :disponible, :boolean, default: true

  def duracion_cita
    return 0 unless hora_inicio.present? && hora_fin.present?
    ((hora_fin - hora_inicio) / 60).to_i
  end

  def nombre_dia
    case fecha.wday
    when 0 then 'Domingo'
    when 1 then 'Lunes' 
    when 2 then 'Martes'
    when 3 then 'Miércoles'
    when 4 then 'Jueves'
    when 5 then 'Viernes'
    when 6 then 'Sábado'
    end
  end

  def fecha_formateada
    fecha.strftime('%d de %B de %Y')
  end

  private

  def fecha_no_pasada
    return unless fecha.present?
    if fecha < Date.today
      errors.add(:fecha, "no puede ser en el pasado")
    end
  end

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
    return unless doctor_id.present? && fecha.present? && hora_inicio.present? && hora_fin.present?
    
    horarios_solapados = HorarioAtencion.where(doctor_id: doctor_id, fecha: fecha)
                                      .where.not(id: id)
                                      .where("(hora_inicio < ? AND hora_fin > ?) OR (hora_inicio < ? AND hora_fin > ?)", 
                                             hora_fin, hora_inicio, hora_inicio, hora_fin)
    
    if horarios_solapados.exists?
      errors.add(:base, "El horario se solapa con otro horario existente")
    end
  end
end