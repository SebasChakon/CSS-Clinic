class CreateResenas < ActiveRecord::Migration[7.1]
  def change
    create_table :resenas do |t|
      t.references :reserva, null: false, foreign_key: true
      t.references :autor, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end

    add_index :resenas, [:reserva_id, :autor_id], unique: true
  end
end
