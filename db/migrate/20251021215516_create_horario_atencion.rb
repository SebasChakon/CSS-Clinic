# frozen_string_literal: true

class CreateHorarioAtencion < ActiveRecord::Migration[7.0]
  def change
    create_table :horario_atencions do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.integer :dia_semana, null: false
      t.time :hora_inicio, null: false
      t.time :hora_fin, null: false
      t.boolean :disponible, default: true

      t.timestamps
    end

    add_index :horario_atencions, %i[doctor_id dia_semana hora_inicio], unique: true,
                                                                        name: 'idx_horario_doctor_dia_hora'
  end
end
