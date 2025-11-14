# frozen_string_literal: true

class ReservasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reserva, only: %i[show edit update cancelar confirmar completar]

  def index
    if current_user.admin?
      @reservas = Reserva.includes(:paciente, :doctor, resenas: :autor).order(fecha_hora: :desc)

      case params[:filtro]
      when 'pendientes'
        @reservas = @reservas.pendiente.order(fecha_hora: :asc)
      when 'confirmadas'
        @reservas = @reservas.confirmada.order(fecha_hora: :asc)
      when 'canceladas'
        @reservas = @reservas.cancelada.order(fecha_hora: :desc)
      when 'completadas'
        @reservas = @reservas.completada.order(fecha_hora: :desc)
      end

    elsif current_user.paciente?
      @reservas = current_user.reservas_paciente.includes(:doctor, resenas: :autor).order(fecha_hora: :desc)

      case params[:filtro]
      when 'pendientes'
        @reservas = @reservas.pendiente.order(fecha_hora: :asc)
      when 'confirmadas'
        @reservas = @reservas.confirmada.order(fecha_hora: :asc)
      when 'canceladas'
        @reservas = @reservas.cancelada.order(fecha_hora: :desc)
      when 'completadas'
        @reservas = @reservas.completada.order(fecha_hora: :desc)
      end

      @proxima_cita = current_user.reservas_paciente
                                  .includes(:doctor)
                                  .where(fecha_hora: DateTime.now..)
                                  .where(estado: %i[pendiente confirmada])
                                  .order(fecha_hora: :asc)
                                  .first

    elsif current_user.doctor?
      @reservas = current_user.reservas_doctor.includes(:paciente, resenas: :autor).order(fecha_hora: :desc)

      case params[:filtro]
      when 'proximas'
        @reservas = @reservas.where(fecha_hora: DateTime.now..).order(fecha_hora: :asc)
      when 'pasadas'
        @reservas = @reservas.where(fecha_hora: ...DateTime.now).order(fecha_hora: :desc)
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
                                  .where(fecha_hora: DateTime.now..)
                                  .where(estado: %i[pendiente confirmada])
                                  .order(fecha_hora: :asc)
                                  .first

      @estadisticas = {
        total: current_user.reservas_doctor.count,
        pendientes: current_user.reservas_doctor.pendiente.count,
        confirmadas: current_user.reservas_doctor.confirmada.count,
        canceladas: current_user.reservas_doctor.cancelada.count,
        completadas: current_user.reservas_doctor.completada.count

      }

    end
  end

  def show
    @resenas = @reserva.resenas.includes(:autor).order(created_at: :desc)
  end

  def new
    if current_user.paciente?
      @doctor = User.doctores.find(params[:doctor_id])
      @horarios_disponibles = @doctor.horario_atencions.disponibles.futuros.order(:fecha, :hora_inicio)
      @reserva = Reserva.new(doctor: @doctor)
    else
      redirect_to reservas_path, alert: 'Solo los pacientes pueden agendar citas'
    end
  end

  def edit
    redirect_to reservas_path, alert: 'No tienes permisos para editar esta reserva' unless current_user.doctor?

    return unless @reserva.cancelada?

    redirect_to @reserva, alert: 'No se pueden editar notas de una cita cancelada'
  end

  def create
    if current_user.paciente?
      horario_id = params[:reserva].delete(:horario_id)
      horario_seleccionado = HorarioAtencion.find_by(id: horario_id) if horario_id.present?

      if horario_seleccionado
        reserva_final_params = reserva_params.merge(
          doctor_id: horario_seleccionado.doctor_id,
          fecha_hora: "#{horario_seleccionado.fecha} #{horario_seleccionado.hora_inicio.strftime('%H:%M')}",
          duracion: horario_seleccionado.duracion_cita,
          ubicacion: horario_seleccionado.ubicacion
        )

        @reserva = current_user.reservas_paciente.new(reserva_final_params)
        horario_seleccionado.update(disponible: false)
      else
        @reserva = current_user.reservas_paciente.new(reserva_params)
      end

      if @reserva.save
        redirect_to @reserva, notice: 'Cita agendada exitosamente. Espera la confirmación del médico.'
      else
        @doctor = User.doctores.find(params[:reserva][:doctor_id])
        @horarios_disponibles = @doctor.horario_atencions.disponibles.futuros.order(:fecha, :hora_inicio)
        render :new
      end
    else
      redirect_to reservas_path, alert: 'Solo los pacientes pueden agendar citas'
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

  def farmacias_cercanas
    latitud = params[:lat] || (session[:ultima_ubicacion] && session[:ultima_ubicacion]['lat']) || (session[:ultima_ubicacion] && session[:ultima_ubicacion][:lat])
    longitud = params[:lng] || (session[:ultima_ubicacion] && session[:ultima_ubicacion]['lng']) || (session[:ultima_ubicacion] && session[:ultima_ubicacion][:lng])
    if latitud.blank? || longitud.blank?
      redirect_to root_path, alert: "No se pudieron obtener las coordenadas. Usa 'Ubicación real' primero."
      return
    end

    @farmacias = NominatimService.buscar_farmacias(latitud, longitud)
    session[:ultimas_farmacias] = @farmacias
    session[:ultima_ubicacion] = {
      lat: latitud.to_f,
      lng: longitud.to_f
    }
    redirect_to root_path, notice: "Encontradas #{@farmacias.count} farmacias cerca de ti"
  end

  private

  def set_reserva
    if current_user.admin?
      @reserva = Reserva.find(params[:id])
    elsif current_user.paciente?
      @reserva = current_user.reservas_paciente.find(params[:id])
    elsif current_user.doctor?
      @reserva = current_user.reservas_doctor.find(params[:id])
    end
  end

  def reserva_params
    if current_user.doctor?
      params.require(:reserva).permit(:notas)
    else
      params.require(:reserva).permit(:doctor_id, :fecha_hora, :motivo, :duracion, :ubicacion)
    end
  end
end
