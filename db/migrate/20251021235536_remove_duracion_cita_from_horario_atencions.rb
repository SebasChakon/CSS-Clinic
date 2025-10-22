class RemoveDuracionCitaFromHorarioAtencions < ActiveRecord::Migration[7.0]
  def change
    remove_column :horario_atencions, :duracion_cita, :integer
  end
end