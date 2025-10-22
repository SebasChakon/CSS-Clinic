class ReservasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reserva, only: [:show, :edit, :update, :cancelar, :confirmar, :completar]

  def index
    if current_user.paciente?
      @reservas = current_user.reservas_paciente.includes(:doctor).order(fecha_hora: :desc)
      
      case params[:filtro]
      when 'proximas'
        @reservas = @reservas.where('fecha_hora >= ?', DateTime.now).order(fecha_hora: :asc)
      when 'pasadas'
        @reservas = @reservas.where('fecha_hora < ?', DateTime.now).order(fecha_hora: :desc)
      when 'pendientes'
        @reservas = @reservas.pendiente.order(fecha_hora: :asc)
      when 'confirmadas'
        @reservas = @reservas.confirmada.order(fecha_hora: :asc)
      end
      
      @proxima_cita = current_user.reservas_paciente
                                 .includes(:doctor)
                                 .where('fecha_hora >= ?', DateTime.now)
                                 .where(estado: [:pendiente, :confirmada])
                                 .order(fecha_hora: :asc)
                                 .first

    elsif current_user.doctor?
      @reservas = current_user.reservas_doctor.includes(:paciente).order(fecha_hora: :desc)
      
      case params[:filtro]
      when 'proximas'
        @reservas = @reservas.where('fecha_hora >= ?', DateTime.now).order(fecha_hora: :asc)
      when 'pasadas'
        @reservas = @reservas.where('fecha_hora < ?', DateTime.now).order(fecha_hora: :desc)
      when 'pendientes'
        @reservas = @reservas.pendiente.order(fecha_hora: :asc)
      when 'confirmadas'
        @reservas = @reservas.confirmada.order(fecha_hora: :asc)
      when 'canceladas'
        @reservas = @reservas.cancelada.order(fecha_hora: :desc)
      when 'completadas'
        @reservas = @reservas.completada.order(fecha_hora: :desc)
      end
      
      @proxima_cita = current_user.reservas_doctor
                                 .includes(:paciente)
                                 .where('fecha_hora >= ?', DateTime.now)
                                 .where(estado: [:pendiente, :confirmada])
                                 .order(fecha_hora: :asc)
                                 .first
      
      @estadisticas = {
        total: current_user.reservas_doctor.count,
        pendientes: current_user.reservas_doctor.pendiente.count,
        confirmadas: current_user.reservas_doctor.confirmada.count,
        proximas: current_user.reservas_doctor.where('fecha_hora >= ?', DateTime.now).count
      }
    end
  end

  def show
  end

  def edit
    unless current_user.doctor?
      redirect_to reservas_path, alert: 'No tienes permisos para editar esta reserva'
    end
    
    if @reserva.cancelada?
      redirect_to @reserva, alert: 'No se pueden editar notas de una cita cancelada'
    end
  end

  def update
    if current_user.doctor?
      if @reserva.cancelada?
        redirect_to @reserva, alert: 'No se pueden editar notas de una cita cancelada'
      elsif @reserva.update(reserva_params)
        redirect_to @reserva, notice: 'Notas actualizadas exitosamente.'
      else
        render :edit
      end
    else
      redirect_to reservas_path, alert: 'No tienes permisos para editar esta reserva'
    end
  end

  def confirmar
    if current_user.doctor?
      if @reserva.update(estado: :confirmada)
        redirect_to @reserva, notice: 'Reserva confirmada exitosamente.'
      else
        render :show, alert: 'No se pudo confirmar la reserva.'
      end
    else
      redirect_to reservas_path, alert: 'Solo los médicos pueden confirmar reservas'
    end
  end

  def completar
    if current_user.doctor?
      if @reserva.update(estado: :completada)
        redirect_to @reserva, notice: 'Reserva marcada como completada.'
      else
        render :show, alert: 'No se pudo completar la reserva.'
      end
    else
      redirect_to reservas_path, alert: 'Solo los médicos pueden marcar reservas como completadas'
    end
  end

  def cancelar
    if @reserva.update(estado: :cancelada)
      redirect_to @reserva, notice: 'Reserva cancelada exitosamente.'
    else
      render :show, alert: 'No se pudo cancelar la reserva.'
    end
  end

  def new
    if current_user.paciente?
      @doctor = User.doctores.find(params[:doctor_id])
      
      # Obtener horarios disponibles del doctor
      @horarios_disponibles = @doctor.horario_atencions.disponibles.order(:dia_semana, :hora_inicio)
      
      # Valores por defecto
      duracion_default = @horarios_disponibles.first&.duracion_cita || 30
      ubicacion_default = @horarios_disponibles.first&.ubicacion || "Consultorio del doctor"
      
      @reserva = Reserva.new(
        doctor: @doctor,
        duracion: duracion_default,
        ubicacion: ubicacion_default
      )
    else
      redirect_to reservas_path, alert: 'Solo los pacientes pueden agendar citas'
    end
  end

  def create
    if current_user.paciente?
      @reserva = current_user.reservas_paciente.new(reserva_params)
      
      # Buscar el horario seleccionado para obtener duración, ubicación y MARCAR COMO NO DISPONIBLE
      if params[:reserva][:fecha_hora].present?
        fecha_hora = DateTime.parse(params[:reserva][:fecha_hora])
        dia_semana = fecha_hora.strftime('%A').downcase
        hora_inicio = fecha_hora.strftime('%H:%M')
        
        horario_seleccionado = HorarioAtencion.find_by(
          doctor_id: params[:reserva][:doctor_id],
          dia_semana: dia_semana,
          hora_inicio: hora_inicio
        )
        
        if horario_seleccionado
          @reserva.duracion = horario_seleccionado.duracion_cita
          @reserva.ubicacion = horario_seleccionado.ubicacion
          
          # MARCAR EL HORARIO COMO NO DISPONIBLE
          horario_seleccionado.update(disponible: false)
        end
      end
      
      if @reserva.save
        redirect_to @reserva, notice: 'Cita agendada exitosamente. Espera la confirmación del médico.'
      else
        @doctor = User.doctores.find(params[:reserva][:doctor_id])
        @horarios_disponibles = @doctor.horario_atencions.disponibles.order(:dia_semana, :hora_inicio)
        render :new
      end
    else
      redirect_to reservas_path, alert: 'Solo los pacientes pueden agendar citas'
    end
  end


  private

  def set_reserva
    if current_user.paciente?
      @reserva = current_user.reservas_paciente.find(params[:id])
    elsif current_user.doctor?
      @reserva = current_user.reservas_doctor.find(params[:id])
    end
  end

  def reserva_params
    if current_user.doctor?
      params.require(:reserva).permit(:notas)
    else
      # Pacientes pueden crear reservas con estos campos
      params.require(:reserva).permit(:doctor_id, :fecha_hora, :motivo, :duracion, :ubicacion)
    end
  end
end