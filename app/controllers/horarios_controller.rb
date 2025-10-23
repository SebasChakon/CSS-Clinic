class HorariosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_horario, only: [:edit, :update, :destroy]

  def index
    if current_user.doctor?
      @horarios = current_user.horario_atencions.futuros.order(:fecha, :hora_inicio)
      @nuevo_horario = HorarioAtencion.new
      render 'doctor_index'
    else
      @doctores = User.doctores.joins(:horario_atencions)
                      .where(horario_atencions: { disponible: true, fecha: Date.today.. })
                      .distinct
      render 'paciente_index'
    end
  end

  def new
    authorize_doctor
    @horario = HorarioAtencion.new
  end

  def create
    authorize_doctor
    @horario = current_user.horario_atencions.new(horario_params)
    
    if @horario.save
      redirect_to horarios_path, notice: 'Horario agregado exitosamente.'
    else
      render :new
    end
  end

  def edit
    authorize_doctor
  end

  def update
    authorize_doctor
    if @horario.update(horario_params)
      redirect_to horarios_path, notice: 'Horario actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    authorize_doctor
    @horario.destroy
    redirect_to horarios_path, notice: 'Horario eliminado exitosamente.'
  end

  private

  def set_horario
    @horario = current_user.horario_atencions.find(params[:id])
  end

  def authorize_doctor
    unless current_user.doctor?
      redirect_to root_path, alert: 'No tienes permisos para acceder a esta página.'
    end
  end

  def horario_params
    params.require(:horario_atencion).permit(:fecha, :hora_inicio, :hora_fin, :ubicacion)
  end
end