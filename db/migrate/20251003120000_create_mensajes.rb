# frozen_string_literal: true

class CreateMensajes < ActiveRecord::Migration[7.1]
  def change
    create_table :mensajes do |t|
      t.references :reserva, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :contenido, null: false

      t.timestamps
    end
  end
end
