class AddDuracionAndUbicacionToReservas < ActiveRecord::Migration[7.1]
  def change
    add_column :reservas, :duracion, :integer, default: 30, null: false
    add_column :reservas, :ubicacion, :string, default: 'Consultorio Principal', null: false
  end
end
