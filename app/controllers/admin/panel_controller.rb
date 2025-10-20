class Admin::PanelController < Admin::BaseController
  def index
    @usuarios = User.order(created_at: :desc)
    @reservas = Reserva.includes(:paciente, :doctor).order(fecha_hora: :desc)
  end

  def hacer_medico
    user = User.find(params[:id])

    if user.admin?
      redirect_to admin_panel_path, alert: "No se puede convertir a un admin en médico."
      return
    end

    if user.doctor?
      redirect_to admin_panel_path, notice: "#{user.nombre_completo} ya es médico."
      return
    end

    
    if user.doctor!
      redirect_to admin_panel_path, notice: "#{user.nombre_completo} ahora es médico."
    else
      redirect_to admin_panel_path, alert: "No se pudo actualizar el usuario."
    end
  end
end
