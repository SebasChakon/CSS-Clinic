class ReservasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reserva, only: [:show, :edit, :update, :cancelar]

  # GET /reservas - Lista mis reservas
  def index
    # Reservas del usuario
    @reservas = current_user.reservas_paciente.includes(:doctor).order(fecha_hora: :desc)
    
    # Filtros
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
    
    # Próxima cita (la más cercana en el futuro)
    @proxima_cita = current_user.reservas_paciente
                               .includes(:doctor)
                               .where('fecha_hora >= ?', DateTime.now)
                               .where(estado: [:pendiente, :confirmada])
                               .order(fecha_hora: :asc)
                               .first
  end

  # GET /reservas/1 - Ver detalle de reserva
  def show
  end

  # GET /reservas/1/edit - Editar reserva
  def edit
  end

  # PATCH/PUT /reservas/1 - Actualizar reserva
  def update
    if @reserva.update(reserva_params)
      redirect_to @reserva, notice: 'Reserva actualizada exitosamente.'
    else
      render :edit
    end
  end

  # PATCH /reservas/1/cancelar - Cancelar reserva
  def cancelar
    if @reserva.update(estado: :cancelada)
      redirect_to @reservas_path, notice: 'Reserva cancelada exitosamente.'
    else
      render :show, alert: 'No se pudo cancelar la reserva.'
    end
  end

  private

  def set_reserva
    @reserva = current_user.reservas_paciente.find(params[:id])
  end

  def reserva_params
    params.require(:reserva).permit(:motivo, :notas)
  end
end