class CreateReservas < ActiveRecord::Migration[7.1]
  def change
    create_table :reservas do |t|
      t.references :paciente, null: false, foreign_key: { to_table: :users }
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.datetime :fecha_hora, null: false
      t.text :motivo, null: false
      t.text :notas
      t.integer :estado, default: 0
      
      t.timestamps
    end
  end
end