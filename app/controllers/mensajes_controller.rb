class MensajesController < ApplicationController
  before_action :set_reserva
  before_action :authenticate_user!

  def index
    @mensajes = @reserva.mensajes.includes(:user).order(:created_at)
    @mensaje = @reserva.mensajes.new
  end

  def create
    @mensaje = @reserva.mensajes.new(mensaje_params)
    @mensaje.user = current_user

    if @mensaje.save
      redirect_to reserva_mensajes_path(@reserva), notice: "Mensaje enviado"
    else
      @mensajes = @reserva.mensajes.includes(:user).order(:created_at)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_reserva
    @reserva = Reserva.find(params[:reserva_id])
  end

  def mensaje_params
    params.require(:mensaje).permit(:contenido)
  end
end