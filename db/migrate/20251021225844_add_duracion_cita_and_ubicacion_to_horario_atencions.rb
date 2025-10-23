class AddDuracionCitaAndUbicacionToHorarioAtencions < ActiveRecord::Migration[7.1]
  def change
    add_column :horario_atencions, :duracion_cita, :integer
    add_column :horario_atencions, :ubicacion, :string
  end
end
