class ReservasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reserva, only: [:show, :edit, :update, :cancelar, :confirmar, :completar]


  def index
    if current_user.admin?
      @reservas = Reserva.includes(:paciente, :doctor, resenas: :autor).order(fecha_hora: :desc)

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
      
    elsif current_user.paciente?
      @reservas = current_user.reservas_paciente.includes(:doctor, resenas: :autor).order(fecha_hora: :desc)
      
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
      @reservas = current_user.reservas_doctor.includes(:paciente, resenas: :autor).order(fecha_hora: :desc)
      
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
        canceladas: current_user.reservas_doctor.cancelada.count,
        completadas: current_user.reservas_doctor.completada.count,

      }
    end
  end

  def show
    @resenas = @reserva.resenas.includes(:autor).order(created_at: :desc)
  end

  def edit
    # Solo doctores pueden editar y solo si NO está cancelada
    unless current_user.doctor?
      redirect_to reservas_path, alert: 'No tienes permisos para editar esta reserva'
    end
    
    if @reserva.cancelada?
      redirect_to @reserva, alert: 'No se pueden editar notas de una cita cancelada'
    end
  end

  def update
    # Solo doctores pueden editar y solo si NO está cancelada
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
    # Solo doctores pueden confirmar
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
    # Solo doctores pueden completar
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
    # Tanto pacientes como doctores pueden cancelar
    if @reserva.update(estado: :cancelada)
      redirect_to @reserva, notice: 'Reserva cancelada exitosamente.'
    else
      render :show, alert: 'No se pudo cancelar la reserva.'
    end
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
    # SOLO doctores pueden editar notas
    if current_user.doctor?
      params.require(:reserva).permit(:notas)
    else
      # Pacientes NO pueden editar nada
      params.require(:reserva).permit()
    end
  end
end