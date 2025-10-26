# frozen_string_literal: true

class ResenasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reserva
  before_action :ensure_patient!, only: %i[new create]
  before_action :set_resena, only: %i[edit update destroy]
  before_action :ensure_author!, only: %i[edit update destroy]

  def new
    if @reserva.resenas.exists?(autor: current_user)
      redirect_to reserva_path(@reserva), alert: 'Ya dejaste una reseña para esta cita.'
      return
    end

    unless permitido_resenar?(@reserva)
      redirect_to reserva_path(@reserva), alert: 'No puedes reseñar una cita que aún no ha ocurrido.'
      return
    end

    @resena = @reserva.resenas.build
  end

  def edit; end

  def create
    @resena = @reserva.resenas.build(resena_params)
    @resena.autor = current_user

    if @resena.save
      redirect_to reserva_path(@reserva), notice: 'Gracias — tu reseña fue publicada.', status: :see_other
    else
      flash.now[:alert] = @resena.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @resena.update(resena_params)
      redirect_to reserva_path(@reserva), notice: 'Reseña actualizada.', status: :see_other
    else
      flash.now[:alert] = @resena.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resena.destroy
    redirect_to reserva_path(@reserva), notice: 'Reseña eliminada.'
  end

  private

  def set_reserva
    @reserva = Reserva.find(params[:reserva_id])
  end

  def set_resena
    @resena = @reserva.resenas.find(params[:id])
  end

  def ensure_patient!
    return if @reserva.paciente_id == current_user.id

    redirect_to reserva_path(@reserva), alert: 'Solo el paciente puede dejar una reseña.'
  end

  def ensure_author!
    return if @resena.autor_id == current_user.id

    redirect_to reserva_path(@reserva), alert: 'No tienes permiso para editar/eliminar esta reseña.'
  end

  def permitido_resenar?(reserva)
    reserva.fecha_hora.present? && (reserva.fecha_hora < Time.current || (reserva.respond_to?(:completada?) && reserva.completada?))
  end

  def resena_params
    params.require(:resena).permit(:rating, :comment)
  end
end
