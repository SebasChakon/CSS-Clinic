# frozen_string_literal: true

module Admin
  class PanelController < Admin::BaseController
    def index
      @usuarios = User.order(created_at: :desc)
      @reservas = Reserva.includes(:paciente, :doctor).order(fecha_hora: :desc)
    end

    def hacer_medico
      user = User.find(params[:id])

      if user.admin?
        flash[:alert] = 'No se puede convertir a un admin en médico.'
        redirect_to admin_panel_path
        return
      end

      if user.doctor?
        flash[:notice] = "#{user.nombre_completo} ya es médico."
        redirect_to admin_panel_path
        return
      end

      if user.doctor!
        flash[:notice] = "#{user.nombre_completo} ahora es médico."
      else
        flash[:alert] = 'No se pudo actualizar el usuario.'
      end
      redirect_to admin_panel_path
    end
  end
end
