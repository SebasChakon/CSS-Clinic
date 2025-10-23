class ChangeHorarioAtencionToSpecificDates < ActiveRecord::Migration[7.0]
  def up
    HorarioAtencion.delete_all
    remove_column :horario_atencions, :dia_semana, :integer
    add_column :horario_atencions, :fecha, :date, null: false
    add_index :horario_atencions, [:doctor_id, :fecha, :hora_inicio], unique: true
  end
end