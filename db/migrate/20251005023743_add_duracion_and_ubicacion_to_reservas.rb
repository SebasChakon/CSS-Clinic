class AddDuracionAndUbicacionToReservas < ActiveRecord::Migration[7.1]
  def change
    add_column :reservas, :duracion, :integer, null: false
    add_column :reservas, :ubicacion, :string, null: false
  end
end