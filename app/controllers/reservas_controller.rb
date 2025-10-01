class ReservasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reserva, only: [:show, :edit, :update, :cancelar]

  # GET /reservas - Lista mis reservas
  def index
    @reservas = current_user.reservas_paciente.includes(:doctor).order(fecha_hora: :desc)
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